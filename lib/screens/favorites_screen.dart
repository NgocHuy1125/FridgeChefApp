import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/models/recipe_model.dart';
import '/providers/favorites_provider.dart';
import '/providers/user_data_provider.dart';
import '/screens/recipe_detail_screen.dart';

class FavoritesScreenWrapper extends StatelessWidget {
  const FavoritesScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDataProvider()..fetchInitialUserData(),
      child: Builder(
        builder: (context) {
          final userData = context.read<UserDataProvider>();
          return ChangeNotifierProvider(
            create: (_) => FavoritesProvider(userData),
            child: const FavoritesScreen(),
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Món ăn yêu thích')),
      body:
          favProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : favProvider.favoriteRecipes.isEmpty
              ? const Center(child: Text('Bạn chưa có món ăn yêu thích nào.'))
              : RefreshIndicator(
                onRefresh:
                    () =>
                        context
                            .read<FavoritesProvider>()
                            .fetchFavoriteRecipes(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: favProvider.favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = favProvider.favoriteRecipes[index];
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
                          onPressed: () async {
                            final userData = context.read<UserDataProvider>();
                            await userData.toggleFavorite(recipe);
                            // Không cần gọi refreshFavorites() nữa
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
              ),
    );
  }
}
