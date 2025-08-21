import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/category_model.dart';
import 'package:fridge_chef_app/screens/category_screen.dart';
import 'package:fridge_chef_app/services/meal_api.dart';
import 'package:http/http.dart' as http;
import '/models/recipe_model.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreenWrapper extends StatelessWidget {
  const SearchScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    final apiService = MealDbApiService();
    try {
      final uri = Uri.parse('${MealDbApiService.mealDbBaseUrl}/categories.php');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          return (data['categories'] as List)
              .map((json) => Category.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm món ăn')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchProvider.searchAllSources(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                searchProvider.searchAllSources(value);
              },
            ),
          ),
          // Hiển thị kết quả tìm kiếm hoặc danh mục nếu chưa tìm
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                switch (provider.status) {
                  case SearchStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case SearchStatus.error:
                    return Center(child: Text(provider.errorMessage));
                  case SearchStatus.success:
                    return _buildRecipeList(provider.searchResults);
                  case SearchStatus.initial:
                  default:
                    return _buildCategoriesSection();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Phần hiển thị danh mục (categories)
  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có danh mục nào'));
        }
        final categories = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryRecipesScreen(category: category),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (category.thumbnail != null)
                      Image.network(
                        category.thumbnail!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Phần hiển thị danh sách món ăn từ kết quả tìm kiếm
  Widget _buildRecipeList(List<RecipeFromApi> recipes) {
    if (recipes.isEmpty) {
      return const Center(child: Text('Không tìm thấy món ăn nào'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return ListTile(
          leading:
              recipe.imageUrl.isNotEmpty
                  ? Image.network(
                    recipe.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(Icons.error),
                  )
                  : const Icon(Icons.fastfood),
          title: Text(recipe.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => RecipeDetailScreenWrapper(
                      recipeId: int.tryParse(recipe.id) ?? 0,
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
