import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';

class UserDataProvider extends ChangeNotifier {
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Set<int> _favoriteRecipeIds = {};

  Set<int> get favoriteRecipeIds => _favoriteRecipeIds;

  Future<void> fetchInitialUserData() async {
    await fetchFavoriteIds();
  }

  // Tải danh sách ID các món yêu thích từ Supabase
  Future<void> fetchFavoriteIds() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final response = await supabase
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', userId);

      _favoriteRecipeIds =
          response.map<int>((item) => item['recipe_id'] as int).toSet();
      notifyListeners();
    } catch (e) {
      print('Error fetching favorite IDs: $e');
    }
  }

  bool isFavorite(int recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final recipeId = recipe.id;
    final currentlyFavorite = isFavorite(recipeId);

    if (currentlyFavorite) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
    notifyListeners();

    try {
      if (currentlyFavorite) {
        await supabase.from('user_favorites').delete().match({
          'user_id': userId,
          'recipe_id': recipeId,
        });
      } else {
        await supabase.from('user_favorites').insert({
          'user_id': userId,
          'recipe_id': recipeId,
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');

      await fetchFavoriteIds();
    }
  }

  Future<void> addToCollection(int recipeId) async {
    print('Added recipe $recipeId to a collection.');
  }
}
