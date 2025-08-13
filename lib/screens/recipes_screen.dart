import 'package:flutter/material.dart';
import 'package:app_goi_y_mon_an/models/recipe.dart';
import 'package:app_goi_y_mon_an/utils/mock_data.dart';
import 'package:app_goi_y_mon_an/screens/home_screen.dart'; // Để điều hướng về HomeScreen
import 'package:app_goi_y_mon_an/screens/favorites_screen.dart'; // Để điều hướng đến FavoritesScreen

class RecipesScreen extends StatefulWidget {
  final List<String> selectedIngredientIds; // Danh sách ID nguyên liệu đã chọn

  const RecipesScreen({super.key, required this.selectedIngredientIds});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<Recipe> _filteredRecipes = [];
  Set<String> _favoritedRecipeIds = {}; // Để kiểm tra trạng thái yêu thích
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Sử dụng didChangeDependencies để cập nhật nếu mockFavoritedRecipeIds thay đổi
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật trạng thái yêu thích từ mock data mỗi khi widget được rebuild/route thay đổi
    setState(() {
      _favoritedRecipeIds = mockFavoritedRecipeIds.toSet();
    });
  }

  void _loadRecipes() {
    // Trong thực tế, bạn sẽ gọi API ở đây:
    // final fetchedRecipes = await YourApiService().getRecipesByIngredients(widget.selectedIngredientIds);

    // Dùng dữ liệu giả lập cho mục đích hiển thị UI
    List<Recipe> recipes = [];

    if (widget.selectedIngredientIds.isEmpty) {
      // Nếu không có nguyên liệu nào được chọn, hiển thị tất cả công thức
      recipes = List.from(mockRecipes);
    } else {
      // Lọc các công thức dựa trên nguyên liệu đã chọn
      // Một công thức được coi là phù hợp nếu ít nhất một trong các nguyên liệu yêu cầu
      // của nó có trong danh sách nguyên liệu đã chọn của người dùng.
      // Bạn có thể tùy chỉnh logic lọc ở đây (ví dụ: cần N% nguyên liệu, hoặc tất cả nguyên liệu chính).
      for (var recipe in mockRecipes) {
        if (recipe.requiredIngredientIds != null && recipe.requiredIngredientIds!.isNotEmpty) {
          bool hasMatchingIngredient = recipe.requiredIngredientIds!
              .any((requiredId) => widget.selectedIngredientIds.contains(requiredId));
          if (hasMatchingIngredient) {
            recipes.add(recipe);
          }
        }
      }
    }

    // Sắp xếp các công thức (ví dụ: theo thời gian tạo, mới nhất lên đầu)
    recipes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    setState(() {
      _filteredRecipes = recipes;
      _favoritedRecipeIds = mockFavoritedRecipeIds.toSet(); // Đảm bảo cập nhật trạng thái yêu thích
      _isLoading = false;
    });
  }

  void _toggleFavorite(Recipe recipe) {
    if (recipe.id == null) return;

    setState(() {
      if (_favoritedRecipeIds.contains(recipe.id)) {
        _favoritedRecipeIds.remove(recipe.id);
        mockFavoritedRecipeIds.remove(recipe.id); // Cập nhật mock data chung
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã bỏ yêu thích món "${recipe.name}"'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _favoritedRecipeIds.add(recipe.id!);
        mockFavoritedRecipeIds.add(recipe.id!); // Cập nhật mock data chung
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${recipe.name}" vào mục yêu thích!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
    // Trong thực tế, bạn sẽ gọi API để cập nhật trạng thái yêu thích trên backend
    // await YourApiService().toggleFavorite(userId, recipe.id, _favoritedRecipeIds.contains(recipe.id));
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
              'Thực đơn phù hợp', // Tên màn hình mới
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Tìm thấy ${_filteredRecipes.length} công thức',
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
          : _filteredRecipes.isEmpty
              ? Center(
                  child: Text(
                    'Không tìm thấy công thức phù hợp với nguyên liệu của bạn.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _filteredRecipes[index];
                    final isFavorited = _favoritedRecipeIds.contains(recipe.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hình ảnh món ăn
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.25 * 0.75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: NetworkImage(recipe.imageUrl ?? 'https://placehold.co/600x400/CCCCCC/FFFFFF?text=No_Image'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            // Thông tin món ăn
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    recipe.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recipe.cookingTimeMinutes} phút',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        recipe.difficulty,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Nút tim
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited ? Colors.red : Colors.grey,
                                  size: 28,
                                ),
                                onPressed: () => _toggleFavorite(recipe),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
        currentIndex: 1, // Đặt mục "Thực đơn" là được chọn
        onTap: (index) {
          if (index == 0) { // Quay về màn hình Tủ bếp
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) { // Đến màn hình Yêu thích
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          }
          // Các tab khác không xử lý điều hướng nếu không có màn hình tương ứng
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
                  child: const Text(
                    'Tủ bếp của tôi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Nút "Xem công thức" trên màn hình này có thể không cần thiết,
                    // hoặc có thể làm một chức năng khác (ví dụ: làm mới tìm kiếm)
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
                    'Tìm lại', // Đổi tên nút cho phù hợp với context
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