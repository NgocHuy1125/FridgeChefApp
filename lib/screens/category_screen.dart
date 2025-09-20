import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fridge_chef_app/models/recipe_model.dart';
import 'package:fridge_chef_app/screens/recipe_detail_screen.dart';
import 'package:provider/provider.dart';
import '/providers/search_provider.dart';
import '/models/category_model.dart';

class CategoryRecipesScreen extends StatelessWidget {
  final Category category;

  const CategoryRecipesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SearchProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Món ăn - ${category.name}')),
      body: FutureBuilder<List<RecipeFromApi>>(
        future: provider.getRecipesByCategory(category.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text('Lỗi hoặc không có món ăn trong danh mục này.'),
            );
          }
          final recipes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: recipe.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget:
                          (c, u, e) => const Icon(
                            Icons.fastfood,
                            size: 60,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Loại: ${category.name}',
                    style: const TextStyle(color: Colors.grey),
                  ),
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
        },
      ),
    );
  }
}
