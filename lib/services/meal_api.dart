import 'dart:convert';
import '/models/recipe_model.dart';
import 'package:http/http.dart' as http;
import 'package:fridge_chef_app/services/api_constants.dart';

class MealDbApiService {
  Future<List<String>> getAllIngredientNames() async {
    final uri = Uri.parse(
      '${ApiConstants.mealDbBaseUrl}${ApiConstants.listIngredientsEndpoint}?i=list',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final List<dynamic> ingredientList = data['meals'];
          return ingredientList
              .map((json) => json['strIngredient'] as String)
              .where((name) => name != null && name.isNotEmpty)
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

  Future<List<RecipeFromApi>> suggestRecipes(
    List<String> ingredientNames,
  ) async {
    if (ingredientNames.isEmpty) return [];

    final Set<String> uniqueIngredients =
        ingredientNames
            .map((name) => name.trim().toLowerCase())
            .where((name) => name.isNotEmpty)
            .toSet();

    if (uniqueIngredients.isEmpty) return [];

    try {
      // Lấy danh sách ID món ăn từ mỗi nguyên liệu
      List<Future<List>> futures = 
          uniqueIngredients.map((ingredient) async {
            final uri = Uri.parse(
              '${ApiConstants.mealDbBaseUrl}/filter.php?i=${Uri.encodeComponent(ingredient)}',
            );
            final response = await http.get(uri);
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['meals'] != null) {
                return (data['meals'] as List<dynamic>)
                    .map(
                      (meal) => {
                        'idMeal': meal['idMeal'],
                        'name': meal['strMeal'],
                      },
                    )
                    .toList();
              }
            }
            return [];
          }).toList();

      // Chờ tất cả các yêu cầu hoàn thành
      final results = await Future.wait(futures);

      // Tạo map để đếm số lần xuất hiện của mỗi ID món ăn
      Map<String, int> mealCount = {};
      for (var result in results) {
        for (var meal in result) {
          final id = meal['idMeal'] as String;
          mealCount[id] = (mealCount[id] ?? 0) + 1;
        }
      }

      // Lấy các ID món ăn xuất hiện với số lượng nguyên liệu tối đa
      final maxMatches =
          mealCount.values.isNotEmpty
              ? mealCount.values.reduce((a, b) => a > b ? a : b)
              : 0;
      final relevantMealIds =
          mealCount.entries
              .where((entry) => entry.value == maxMatches)
              .map((entry) => entry.key)
              .toList();

      if (relevantMealIds.isEmpty) return [];

      // Lấy chi tiết món ăn từ các ID
      final detailedRecipes = await _fetchRecipeDetails(relevantMealIds);
      return detailedRecipes;
    } catch (e) {
      print('Network Error in suggestRecipes: $e');
      throw Exception('Network Error: Could not fetch suggested meals.');
    }
  }

  Future<List<RecipeFromApi>> _fetchRecipeDetails(List<String> mealIds) async {
    final List<Future<RecipeFromApi?>> futures =
        mealIds.map((id) async {
          final uri = Uri.parse(
            '${ApiConstants.mealDbBaseUrl}/lookup.php?i=$id',
          );
          final response = await http.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['meals'] != null && data['meals'].length > 0) {
              return RecipeFromApi.fromJson(data['meals'][0]);
            }
          }
          return null;
        }).toList();

    final results = await Future.wait(futures);
    return results.whereType<RecipeFromApi>().toList();
  }
}
