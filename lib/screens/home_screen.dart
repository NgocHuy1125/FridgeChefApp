import 'package:flutter/material.dart';
import 'package:app_goi_y_mon_an/models/ingredient.dart';
import 'package:app_goi_y_mon_an/screens/favorites_screen.dart'; // Import màn hình yêu thích
import 'package:app_goi_y_mon_an/screens/recipes_screen.dart'; // <-- Import màn hình công thức mới
import 'package:app_goi_y_mon_an/utils/mock_data.dart'; // Import mock data

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Ingredient>> _categorizedIngredients = {};
  Set<String> _userIngredientIds = {}; // Set chứa ID của các nguyên liệu đã chọn
  int _pantryEssentialsTotalCount = 0;
  bool _isLoading = true;
  Set<String> _expandedCategories = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    await _loadIngredients();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadIngredients() async {
    final allIngredientsFromMock = sampleIngredients;

    // Giả lập một số nguyên liệu người dùng đã chọn ban đầu
    // Có thể lưu trạng thái này vào SharedPreferences hoặc một Store nào đó nếu cần persistent
    _userIngredientIds = {'ing_1', 'ing_4', 'ing_7'}.toSet(); // Ví dụ: Cà rốt, Tỏi, Thịt gà

    Map<String, List<Ingredient>> categorized = {};
    for (var ingredient in allIngredientsFromMock) {
      final category = ingredient.category ?? 'Chưa phân loại';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(ingredient);
    }

    setState(() {
      _categorizedIngredients = categorized;
      _pantryEssentialsTotalCount = _userIngredientIds.length;
      _expandedCategories = categorized.keys.toSet();
    });
  }

  void _toggleIngredientInPantry(Ingredient ingredient) {
    if (ingredient.id == null) return;

    setState(() {
      if (_userIngredientIds.contains(ingredient.id)) {
        _userIngredientIds.remove(ingredient.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${ingredient.name}" khỏi tủ bếp!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _userIngredientIds.add(ingredient.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${ingredient.name}" vào tủ bếp!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
      _pantryEssentialsTotalCount = _userIngredientIds.length;
    });
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

  void _handleSearchSubmit(String searchText) {
    if (searchText.isEmpty) return;

    final normalizedSearchText = searchText.trim().toLowerCase();
    final foundIngredient = _categorizedIngredients.values
        .expand((list) => list)
        .firstWhere(
          (ingredient) => ingredient.name.toLowerCase() == normalizedSearchText,
          orElse: () => Ingredient(name: ''),
        );

    if (foundIngredient.name.isNotEmpty) {
      _toggleIngredientInPantry(foundIngredient);
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy nguyên liệu: "$searchText"'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
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
              'Tủ bếp',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Bạn có $_pantryEssentialsTotalCount Nguyên liệu',
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
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        controller: _searchController,
                        onSubmitted: _handleSearchSubmit,
                        decoration: const InputDecoration(
                          hintText: 'Thêm/xóa/dán nguyên liệu',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nguyên liệu cần thiết',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
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
            label: 'Tủ bếp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Mua sắm',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          } else if (index == 1) { // <-- Điều hướng đến màn hình Thực đơn
             Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => RecipesScreen(
                selectedIngredientIds: _userIngredientIds.toList(),
              )),
            );
          }
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
                    // Chuyển đến màn hình Tủ bếp của tôi nếu có (hoặc tự xử lý)
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
                    'Tủ bếp của tôi ($_pantryEssentialsTotalCount)',
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
                    // <-- Khi nhấn nút này, chuyển sang màn hình công thức
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RecipesScreen(
                        selectedIngredientIds: _userIngredientIds.toList(),
                      )),
                    );
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
                    'Xem công thức',
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