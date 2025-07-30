import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import '/services/meal_api.dart';

enum SearchStatus { initial, loading, success, error }

class SearchProvider extends ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();

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

  SearchStatus _status = SearchStatus.initial;
  SearchStatus get status => _status;

  // State bây giờ sẽ lưu List<RecipeFromApi> thay vì List<Recipe>
  List<RecipeFromApi> _searchResults = [];
  List<RecipeFromApi> get searchResults => _searchResults;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> search(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      _status = SearchStatus.initial;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _status = SearchStatus.loading;
    notifyListeners();

    try {
      // Chỉ cần gọi API và gán kết quả
      _searchResults = await _apiService.searchRecipes(trimmedKeyword);
      _status = SearchStatus.success;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      print('Search Error: $e');
    } finally {
      notifyListeners();
    }
  }
}
