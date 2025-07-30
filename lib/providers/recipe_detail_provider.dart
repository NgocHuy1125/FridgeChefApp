// import 'package:flutter/material.dart';
// import '/models/recipe_model.dart';
// import 'package:fridge_chef_app/main.dart';

// enum DetailStatus { loading, success, error }

// class RecipeDetailProvider extends ChangeNotifier {
//   Recipe? _recipe;
//   Recipe? get recipe => _recipe;

//   DetailStatus _status = DetailStatus.loading;
//   DetailStatus get status => _status;

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;

//   // State mới để theo dõi tiến độ nấu ăn
//   late Set<int> _completedSteps;
//   Set<int> get completedSteps => _completedSteps;

//   int get totalSteps =>
//       _recipe?.instructions
//           ?.split('\n')
//           .where((s) => s.trim().isNotEmpty)
//           .length ??
//       0;

//   RecipeDetailProvider() {
//     _completedSteps = {};
//   }

//   // Hàm đánh dấu/bỏ đánh dấu một bước
//   void toggleStep(int stepIndex) {
//     if (_completedSteps.contains(stepIndex)) {
//       _completedSteps.remove(stepIndex);
//     } else {
//       _completedSteps.add(stepIndex);
//     }
//     notifyListeners();
//   }

//   Future<void> fetchRecipeDetails(int recipeId) async {
//     _status = DetailStatus.loading;
//     notifyListeners();
//     try {
//       final response =
//           await supabase
//               .from('recipes')
//               .select('*, recipe_ingredients(*, ingredients(*))')
//               .eq('id', recipeId)
//               .single();
//       _recipe = Recipe.fromJson(response);
//       _status = DetailStatus.success;
//     } catch (e) {
//       _status = DetailStatus.error;
//       _errorMessage = 'Không thể tải dữ liệu món ăn.';
//       print('Error fetching recipe details: $e');
//     } finally {
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/ingredient_model.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/services/meal_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum DetailStatus { loading, success, error }

class RecipeDetailProvider extends ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  DetailStatus _status = DetailStatus.loading;
  DetailStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  late Set<int> _completedSteps;
  Set<int> get completedSteps => _completedSteps;

  int get totalSteps =>
      _recipe?.instructions
          ?.split('\n')
          .where((s) => s.trim().isNotEmpty)
          .length ??
      0;

  RecipeDetailProvider() {
    _completedSteps = {};
  }

  void toggleStep(int stepIndex) {
    if (_completedSteps.contains(stepIndex)) {
      _completedSteps.remove(stepIndex);
    } else {
      _completedSteps.add(stepIndex);
    }
    notifyListeners();
  }

  Future<void> fetchRecipeDetails(int recipeId) async {
    _status = DetailStatus.loading;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = data['meals'][0];
          final id = int.tryParse(meal['idMeal'] ?? '');
          if (id == null) {
            throw Exception('Invalid recipe ID from MealDB: ${meal['idMeal']}');
          }
          _recipe = Recipe(
            id: id,
            name: meal['strMeal'] ?? 'Unknown',
            imageUrl: meal['strMealThumb'] ?? '',
            ingredients: _parseIngredients(meal),
            instructions: meal['strInstructions'] ?? '',
            difficulty: null,
            cookingTimeMinutes:
                int.tryParse(meal['strCookingTime'] ?? '') ?? null,
          );
          print('Fetched recipe with ID: $id');
          _status = DetailStatus.success;
        } else {
          _status = DetailStatus.error;
          _errorMessage = 'Không tìm thấy chi tiết món ăn.';
        }
      } else {
        _status = DetailStatus.error;
        _errorMessage = 'Lỗi API: ${response.statusCode}';
      }
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage = 'Lỗi mạng hoặc dữ liệu: $e';
      print('Error fetching recipe details: $e');
    } finally {
      notifyListeners();
    }
  }

  List<Ingredient> _parseIngredients(Map<String, dynamic> meal) {
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(
          Ingredient(id: 0, name: '$ingredient ${measure ?? ''}'.trim()),
        );
      }
    }
    return ingredients;
  }
}
