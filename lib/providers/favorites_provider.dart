import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';
import '/providers/user_data_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  final UserDataProvider userDataProvider;

  FavoritesProvider(this.userDataProvider) {
    userDataProvider.addListener(_handleFavoritesChanged);
    fetchFavoriteRecipes();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Recipe> _favoriteRecipes = [];
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  void _handleFavoritesChanged() {
    fetchFavoriteRecipes();
  }

  Future<void> fetchFavoriteRecipes() async {
    _isLoading = true;
    notifyListeners();

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _isLoading = false;
      _favoriteRecipes = [];
      notifyListeners();
      return;
    }

    try {
      final response = await supabase
          .from('user_favorites')
          .select('recipes (*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _favoriteRecipes =
          response.map((item) => Recipe.fromJson(item['recipes'])).toList();
    } catch (e) {
      print('Error fetching favorite recipes: $e');
      _favoriteRecipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    userDataProvider.removeListener(_handleFavoritesChanged);
    super.dispose();
  }

  void refreshFavorites() {
    if (!_isLoading) fetchFavoriteRecipes();
  }
}
