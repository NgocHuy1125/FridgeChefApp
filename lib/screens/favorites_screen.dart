import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fridge_chef_app/screens/recipe_detail_screen.dart';
import '/models/recipe_model.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreenWrapper extends StatelessWidget {
  const FavoritesScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (userDataProvider.favoriteRecipes.isEmpty &&
            !userDataProvider.isLoading) {
          Future.microtask(() {
            userDataProvider.loadAllUserData();
          });
        }
        return const FavoritesScreen();
      },
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.watch<UserDataProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Món ăn yêu thích',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<UserDataProvider>().loadAllUserData(),
        child: _buildBody(context, userDataProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserDataProvider provider) {
    if (provider.isLoading && provider.favoriteRecipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.favoriteRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Chưa có món ăn yêu thích nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.favoriteRecipes.length,
      itemBuilder: (context, index) {
        final recipe = provider.favoriteRecipes[index];
        return _buildFavoriteRecipeCard(context, recipe, provider);
      },
    );
  }

  Widget _buildFavoriteRecipeCard(
    BuildContext context,
    Recipe recipe,
    UserDataProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreenWrapper(recipeId: recipe.id),
            ),
          );
        },
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: recipe.imageUrl ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorWidget:
                  (c, u, e) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMinutes ?? '?'} phút',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                provider.toggleFavorite(recipe);
              },
            ),
          ],
        ),
      ),
    );
  }
}
