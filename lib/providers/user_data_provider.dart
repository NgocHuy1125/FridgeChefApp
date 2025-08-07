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

  Future<void> addToCollection(int recipeId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Kiểm tra đã có trong collection chưa
      final existing =
          await supabase
              .from('collections')
              .select('id')
              .eq('user_id', userId)
              .eq('recipe_id', recipeId)
              .maybeSingle();

      if (existing == null) {
        await supabase.from('collections').insert({
          'user_id': userId,
          'recipe_id': recipeId,
        });
        _favoriteRecipeIds.add(recipeId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding to collection: $e');
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

    try {
      final existingRecipe =
          await supabase
              .from('recipes')
              .select('id')
              .eq('id', recipeId)
              .maybeSingle();

      if (existingRecipe == null) {
        await supabase.from('recipes').insert({
          'id': recipeId,
          'name': recipe.name,
          'image_url': recipe.imageUrl,
          'instructions': recipe.instructions,
          'cooking_time_minutes': recipe.cookingTimeMinutes,
          'difficulty': recipe.difficulty,
          'user_id': userId,
        });
      }

      if (currentlyFavorite) {
        await supabase.from('user_favorites').delete().match({
          'user_id': userId,
          'recipe_id': recipeId,
        });
        _favoriteRecipeIds.remove(recipeId);
      } else {
        await supabase.from('user_favorites').insert({
          'user_id': userId,
          'recipe_id': recipeId,
        });
        _favoriteRecipeIds.add(recipeId);
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
