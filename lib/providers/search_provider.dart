import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/recipe_model.dart';
import '/services/meal_api.dart';

enum SearchStatus { initial, loading, success, error }

class SearchProvider with ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();
  List<RecipeFromApi> _searchResults = [];
  String _errorMessage = '';
  SearchStatus _status = SearchStatus.initial;

  List<RecipeFromApi> get searchResults => _searchResults;
  String get errorMessage => _errorMessage;
  SearchStatus get status => _status;

  Future<void> searchAllSources(String keyword) async {
    if (keyword.isEmpty) {
      _status = SearchStatus.initial;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _status = SearchStatus.loading;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchAllSources(keyword);
      _status =
          _searchResults.isEmpty ? SearchStatus.initial : SearchStatus.success;
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _status = SearchStatus.error;
    }

    notifyListeners();
  }
}
