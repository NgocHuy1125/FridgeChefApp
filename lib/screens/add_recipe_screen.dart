import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fridge_chef_app/models/category_model.dart';
import 'package:fridge_chef_app/models/ingredient_model.dart';
import 'package:fridge_chef_app/providers/user_data_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];

  XFile? _imageFile;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitRecipe() async {
    // Nếu đang trong quá trình xử lý, không làm gì cả để tránh nhấn đúp
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn hình ảnh')));
        return;
      }
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        await context.read<UserDataProvider>().createRecipe(
          name: _nameController.text.trim(),
          instructions: _instructionsController.text.trim(),
          ingredientNames:
              _ingredientControllers.map((c) => c.text.trim()).toList(),
          imageFile: _imageFile!,
          categoryId: _selectedCategoryId!,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo công thức thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      } finally {
        // Chỉ set lại isLoading false nếu widget vẫn còn tồn tại
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<UserDataProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công thức mới')),
      // Đổi body thành một widget duy nhất để dễ quản lý trạng thái loading
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildTextFormField(_nameController, 'Tên món ăn'),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  hint: const Text('Chọn danh mục'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items:
                      categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Vui lòng chọn danh mục' : null,
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  _instructionsController,
                  'Hướng dẫn',
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nguyên liệu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredientControllers.length,
                  itemBuilder: (context, index) {
                    return _buildIngredientAutocompleteField(index);
                  },
                ),
                TextButton.icon(
                  onPressed: _addIngredientField,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Thêm nguyên liệu'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  // Vô hiệu hóa nút bấm khi đang loading
                  onPressed: _isLoading ? null : _submitRecipe,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lưu và chia sẻ'),
                ),
              ],
            ),
          ),
          // Lớp phủ loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            _imageFile != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chọn ảnh món ăn',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator:
          (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Vui lòng không để trống'
                  : null,
    );
  }

  Widget _buildIngredientAutocompleteField(int index) {
    final userDataProvider = context.read<UserDataProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Autocomplete<Ingredient>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return userDataProvider.getFilteredSuggestions(
                  textEditingValue.text,
                );
              },
              displayStringForOption: (Ingredient option) => option.name,
              onSelected: (Ingredient selection) {
                _ingredientControllers[index].text = selection.name;
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                if (_ingredientControllers.length > index) {
                  _ingredientControllers[index] = textEditingController;
                }

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nguyên liệu ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Không được để trống'
                              : null,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: MediaQuery.of(context).size.width - 96,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final Ingredient option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_ingredientControllers.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _removeIngredientField(index),
            ),
        ],
      ),
    );
  }
}
