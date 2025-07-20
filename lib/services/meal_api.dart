import 'dart:convert';
import '/models/recipe_model.dart';
import 'package:http/http.dart' as http;
import 'package:fridge_chef_app/services/api_constants.dart';

class MealDbApiService {
  // SỬA LẠI HOÀN TOÀN HÀM NÀY
  Future<List<String>> getAllIngredientNames() async {
    // 1. Dùng đúng URL endpoint
    final uri = Uri.parse(
      '${ApiConstants.mealDbBaseUrl}${ApiConstants.listIngredientsEndpoint}?i=list',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final List<dynamic> ingredientList = data['meals'];
          // 2. Parse đúng key 'strIngredient'
          return ingredientList
              .map((json) => json['strIngredient'] as String)
              .toList();
        }
        return [];
      } else {
        throw Exception(
          'API Error: Failed to load ingredients. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Network Error in getAllIngredientNames: $e');
      throw Exception('Network Error: Could not fetch ingredients.');
    }
  }

  Future<List<RecipeFromApi>> searchRecipes(String keyword) async {
    final uri = Uri.parse(
      '${ApiConstants.mealDbBaseUrl}${ApiConstants.searchEndpoint}?s=$keyword',
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final List<dynamic> mealList = data['meals'];
          return mealList.map((json) => RecipeFromApi.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'API Error: Failed to load meals. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Network Error in searchRecipes: $e');
      throw Exception('Network Error: Could not fetch meals.');
    }
  }
}
