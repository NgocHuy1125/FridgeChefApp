import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/recipe_model.dart';
import '/screens/recipe_detail_screen.dart';

class SeeMoreScreen extends StatelessWidget {
  final List<Recipe> favoriteRecipes;

  const SeeMoreScreen({super.key, required this.favoriteRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả món ăn yêu thích'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          favoriteRecipes.isEmpty
              ? const Center(child: Text('Không có món ăn nào để hiển thị.'))
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: recipe.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => const Icon(Icons.image),
                      ),
                      title: Text(
                        recipe.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Xử lý bỏ yêu thích món ăn
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa khỏi yêu thích!'),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RecipeDetailScreenWrapper(
                                  recipeId: recipe.id,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
