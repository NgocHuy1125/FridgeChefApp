import 'package:flutter/material.dart';
import 'package:app_goi_y_mon_an/models/ingredient.dart';
import 'package:app_goi_y_mon_an/models/user_profile.dart';
import 'package:app_goi_y_mon_an/models/user_ingredient.dart';
import 'package:app_goi_y_mon_an/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _currentUserId = 'mock_user_123';
  Map<String, List<Ingredient>> _categorizedIngredients = {};
  Set<String> _userIngredientIds = {};
  int _pantryEssentialsTotalCount = 0;
  bool _isLoading = true;
  Set<String> _expandedCategories = {};

  final TextEditingController _searchController = TextEditingController(); // Controller cho thanh tìm kiếm

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng controller khi widget bị dispose
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    // Đảm bảo có một UserProfile giả lập
    UserProfile? existingUser = await _dbHelper.getUserProfileById(_currentUserId);
    if (existingUser == null) {
      await _dbHelper.insertUserProfile(
        UserProfile(
          id: _currentUserId,
          username: 'Người dùng giả lập', // Việt hóa
          email: 'mock@example.com',
          avatarUrl: 'https://via.placeholder.com/150',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    // Thêm dữ liệu mẫu nguyên liệu vào DB nếu chưa có
    await _dbHelper.initializeIngredients();

    // Tải các nguyên liệu và trạng thái của người dùng TỪ DATABASE
    await _loadIngredients();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadIngredients() async {
    final allIngredientsFromDb = await _dbHelper.getIngredients();
    final userAddedIngredientsFromDb = await _dbHelper.getUserIngredients(_currentUserId);

    // Nhóm nguyên liệu theo category
    Map<String, List<Ingredient>> categorized = {};
    for (var ingredient in allIngredientsFromDb) {
      final category = ingredient.category ?? 'Chưa phân loại'; // Việt hóa
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(ingredient);
    }

    setState(() {
      _categorizedIngredients = categorized;
      _userIngredientIds = userAddedIngredientsFromDb.map((ui) => ui.ingredientId!).toSet();
      _pantryEssentialsTotalCount = _userIngredientIds.length;
      _expandedCategories = categorized.keys.toSet(); // Mở rộng tất cả ban đầu
    });
  }

  Future<void> _toggleIngredientInPantry(Ingredient ingredient) async {
    if (ingredient.id == null) return;

    if (_userIngredientIds.contains(ingredient.id)) {
      await _dbHelper.deleteUserIngredient(_currentUserId, ingredient.id!);
    } else {
      await _dbHelper.insertUserIngredient(
        UserIngredient(
          userId: _currentUserId,
          ingredientId: ingredient.id!,
          addedAt: DateTime.now(),
        ),
      );
    }
    _loadIngredients(); // Tải lại dữ liệu để cập nhật UI
  }

  void _toggleCategoryExpansion(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  // Hàm xử lý khi người dùng nhập tìm kiếm và nhấn Enter
  void _handleSearchSubmit(String searchText) async {
    if (searchText.isEmpty) return;

    final normalizedSearchText = searchText.trim().toLowerCase();
    // Tìm kiếm nguyên liệu trong danh sách _allIngredients
    final foundIngredient = _categorizedIngredients.values
        .expand((list) => list) // Làm phẳng map thành một list duy nhất
        .firstWhere(
          (ingredient) => ingredient.name.toLowerCase() == normalizedSearchText,
          orElse: () => Ingredient(name: ''), // Trả về Ingredient rỗng nếu không tìm thấy
        );

    if (foundIngredient.name.isNotEmpty) { // Nếu tìm thấy nguyên liệu
      await _toggleIngredientInPantry(foundIngredient);
      _searchController.clear(); // Xóa văn bản sau khi xử lý
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_userIngredientIds.contains(foundIngredient.id)
              ? 'Đã xóa "${foundIngredient.name}" khỏi tủ bếp!'
              : 'Đã thêm "${foundIngredient.name}" vào tủ bếp!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green, // Màu xanh cho thông báo thành công
        ),
      );
    } else {
      // Không tìm thấy nguyên liệu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy nguyên liệu: "$searchText"'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red, // Màu đỏ cho thông báo lỗi
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.deepOrange),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tủ bếp', // Việt hóa
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Bạn có $_pantryEssentialsTotalCount Nguyên liệu', // Việt hóa
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần tìm kiếm
                  Container(
                    color: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: _searchController, // Gán controller
                        onSubmitted: _handleSearchSubmit, // Xử lý khi nhấn Enter
                        decoration: const InputDecoration(
                          hintText: 'Thêm/xóa/dán nguyên liệu', // Việt hóa
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          // Không có suffixIcon cho mic
                        ),
                      ),
                    ),
                  ),

                  // Phần Pantry Essentials - Chia theo loại
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nguyên liệu cần thiết', // Việt hóa
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        // Duyệt qua từng danh mục nguyên liệu
                        ..._categorizedIngredients.keys.map((category) {
                          final ingredientsInCategory = _categorizedIngredients[category]!;
                          final isExpanded = _expandedCategories.contains(category);
                          final countInPantry = ingredientsInCategory.where((ing) => _userIngredientIds.contains(ing.id)).length;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => _toggleCategoryExpansion(category),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            category,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '$countInPantry/${ingredientsInCategory.length}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                        Icon(
                                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: ingredientsInCategory.map((ingredient) {
                                        final isSelected = _userIngredientIds.contains(ingredient.id);
                                        return FilterChip(
                                          label: Text(ingredient.name),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            _toggleIngredientInPantry(ingredient);
                                          },
                                          selectedColor: Theme.of(context).chipTheme.selectedColor,
                                          backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                                          labelStyle: isSelected
                                              ? Theme.of(context).chipTheme.labelStyle?.copyWith(color: Colors.white)
                                              : Theme.of(context).chipTheme.labelStyle,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            side: BorderSide(
                                              color: isSelected ? Theme.of(context).chipTheme.selectedColor! : Colors.grey.shade300,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Tủ bếp', // Việt hóa
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn', // Việt hóa
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích', // Việt hóa
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Mua sắm', // Việt hóa
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Xử lý chuyển tab ở đây
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý khi nhấn "Tủ bếp của tôi"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Tủ bếp của tôi ($_pantryEssentialsTotalCount)', // Việt hóa
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý khi nhấn "Xem công thức"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Xem công thức', // Việt hóa
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}