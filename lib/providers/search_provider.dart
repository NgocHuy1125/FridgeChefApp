import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/category_model.dart';
import 'package:fridge_chef_app/models/recipe_model.dart';
import '/services/meal_api.dart';
import 'package:http/http.dart' as http;

enum SearchStatus { initial, loading, success, error }

class SearchProvider with ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();

  List<RecipeFromApi> _searchResults = [];
  String _errorMessage = '';
  SearchStatus _status = SearchStatus.initial;

  List<RecipeFromApi> get searchResults => _searchResults;
  String get errorMessage => _errorMessage;
  SearchStatus get status => _status;

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  bool _isCategoriesLoading = false;
  bool get isCategoriesLoading => _isCategoriesLoading;

  Future<void> searchAllSources(String keyword) async {
    // Nếu keyword rỗng, reset về trạng thái ban đầu
    if (keyword.trim().isEmpty) {
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

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty || _isCategoriesLoading) return;

    _isCategoriesLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${MealDbApiService.mealDbBaseUrl}/categories.php');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          _categories =
              (data['categories'] as List)
                  .map((json) => Category.fromJson(json))
                  .toList();
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<List<RecipeFromApi>> getRecipesByCategory(String category) async {
    try {
      final results = await _apiService.fetchRecipesByCategory(category);
      return results;
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: $e');
    }
  }
}
