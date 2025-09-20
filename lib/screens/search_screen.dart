import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/category_model.dart';
import 'package:fridge_chef_app/screens/category_screen.dart';
import '/models/recipe_model.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreenWrapper extends StatelessWidget {
  const SearchScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Không tạo Provider mới ở đây
    return const SearchScreen();
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchProvider>();
      if (provider.categories.isEmpty) {
        provider.fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        context.read<SearchProvider>().searchAllSources(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm món ăn')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên món ăn...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(child: _buildBody(searchProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (_searchController.text.isNotEmpty) {
      switch (provider.status) {
        case SearchStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case SearchStatus.error:
          return Center(child: Text(provider.errorMessage));
        case SearchStatus.success:
          return _buildRecipeList(provider.searchResults);
        case SearchStatus.initial:
          return const Center(child: Text('Không tìm thấy kết quả phù hợp.'));
      }
    } else {
      return _buildCategoriesSection(provider);
    }
  }

  Widget _buildCategoriesSection(SearchProvider provider) {
    if (provider.isCategoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.categories.isEmpty) {
      return const Center(child: Text('Không thể tải danh mục.'));
    }
    final categories = provider.categories;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
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
                builder: (context) => CategoryRecipesScreen(category: category),
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
                CachedNetworkImage(
                  imageUrl: category.thumbnail ?? '',
                  height: 60,
                  width: 60,
                  errorWidget:
                      (c, u, e) => const Icon(Icons.fastfood, size: 60),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeList(List<RecipeFromApi> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(color: Colors.grey[200]),
              ),
            ),
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
          ),
        );
      },
    );
  }
}
