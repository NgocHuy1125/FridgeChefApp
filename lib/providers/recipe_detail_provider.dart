import 'package:flutter/material.dart';
import 'package:fridge_chef_app/models/ingredient_model.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/services/meal_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum DetailStatus { loading, success, error }

class RecipeDetailProvider extends ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  DetailStatus _status = DetailStatus.loading;
  DetailStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  late Set<int> _completedSteps;
  Set<int> get completedSteps => _completedSteps;

  List<String> get steps {
    return _recipe?.instructions
            ?.split('\n')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList() ??
        [];
  }

  int get totalSteps => steps.length;

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
      print('Fetching recipe with ID: $recipeId');
      final supabaseResponse =
          await _supabase
              .from('recipes')
              .select('*, ingredients(*), recipe_ingredients(*)')
              .eq('id', recipeId)
              .maybeSingle();

      final supabaseData = supabaseResponse as Map<String, dynamic>?;

      if (supabaseData != null) {
        _recipe = Recipe.fromJson(supabaseData);
        print('Fetched from Supabase: ${_recipe!.name}');
      } else {
        print('Not found in Supabase, fetching from TheMealDB');
        final uri = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId',
        );
        final mealResponse = await http
            .get(uri)
            .timeout(const Duration(seconds: 10));

        if (mealResponse.statusCode == 200) {
          final data = jsonDecode(mealResponse.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final meal = data['meals'][0];
            _recipe = Recipe(
              id: int.tryParse(meal['idMeal'] ?? '') ?? recipeId,
              name: meal['strMeal'] ?? 'Unknown',
              imageUrl: meal['strMealThumb'] ?? '',
              ingredients: _parseIngredients(meal),
              instructions: meal['strInstructions'] ?? '',
              youtubeUrl: meal['strYoutube'],
            );
            print(
              'Fetched from TheMealDB: ${_recipe!.name}, YouTube URL: ${_recipe!.youtubeUrl ?? "null"}',
            );
          } else {
            throw Exception(
              'Không tìm thấy món ăn với ID: $recipeId trong TheMealDB',
            );
          }
        } else {
          throw Exception('Lỗi API TheMealDB: ${mealResponse.statusCode}');
        }
      }

      _status = DetailStatus.success;
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage =
          e.toString().contains('Exception')
              ? 'Không tìm thấy món ăn với ID: $recipeId'
              : 'Lỗi: $e';
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
