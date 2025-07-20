import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';

class FavoritesProvider extends ChangeNotifier {
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

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Recipe> _favoriteRecipes = [];
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  // Hàm này sẽ tải chi tiết các món ăn dựa trên danh sách ID từ Supabase
  Future<void> fetchFavoriteRecipes() async {
    _isLoading = true;
    notifyListeners();

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Query bảng user_favorites và JOIN để lấy chi tiết từ bảng recipes
      final response = await supabase
          .from('user_favorites')
          .select('recipes (*)') // Dấu * để lấy tất cả các cột của bảng recipes
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _favoriteRecipes =
          response.map((item) => Recipe.fromJson(item['recipes'])).toList();
    } catch (e) {
      print('Error fetching favorite recipes details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
