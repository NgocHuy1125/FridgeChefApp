import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/recipe_model.dart';
import '/providers/user_data_provider.dart';
import 'package:fridge_chef_app/models/ingredient_model.dart';

enum DetailStatus { loading, success, error }

class RecipeDetailProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  DetailStatus _status = DetailStatus.loading;
  DetailStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Set<int> completedSteps = {};

  List<String> get steps {
    return _recipe?.instructions
            ?.split(RegExp(r'\r\n|\n'))
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList() ??
        [];
  }

  int get totalSteps => steps.length;

  void toggleStep(int stepIndex) {
    if (completedSteps.contains(stepIndex)) {
      completedSteps.remove(stepIndex);
    } else {
      completedSteps.add(stepIndex);
    }
    notifyListeners();
  }

  Future<void> fetchRecipeDetails(
    int recipeId,
    UserDataProvider userDataProvider,
  ) async {
    _status = DetailStatus.loading;
    notifyListeners();

    try {
      final supabaseResponse =
          await _supabase
              .from('recipes')
              .select('*, recipe_ingredients(*, ingredients(*))')
              .eq('id', recipeId)
              .maybeSingle();

      if (supabaseResponse != null) {
        _recipe = Recipe.fromJson(supabaseResponse);
      } else {
        final uri = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId',
        );
        final mealResponse = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));

        if (mealResponse.statusCode == 200) {
          final data = jsonDecode(mealResponse.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final mealJson = data['meals'][0];
            final apiRecipe = RecipeFromApi.fromJson(mealJson);

            _recipe = Recipe.fromApi(
              apiRecipe,
            ).copyWith(ingredients: _parseIngredientsFromApi(mealJson));

            await _supabase.from('recipes').upsert({
              'id': _recipe!.id,
              'name': _recipe!.name,
              'instructions': _recipe!.instructions,
              'image_url': _recipe!.imageUrl,
              'youtube_url': _recipe!.youtubeUrl,
              // 'cooking_time_minutes': _recipe!.cookingTimeMinutes,
              // 'difficulty': _recipe!.difficulty,
            }, onConflict: 'id');
          } else {
            throw Exception('Không tìm thấy món ăn với ID: $recipeId');
          }
        } else {
          throw Exception('Lỗi API TheMealDB: ${mealResponse.statusCode}');
        }
      }

      if (_recipe != null) {
        await userDataProvider.addViewToHistory(_recipe!.id);
      }

      _status = DetailStatus.success;
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage = 'Lỗi khi tải chi tiết món ăn: $e';
    } finally {
      notifyListeners();
    }
  }

  List<Ingredient> _parseIngredientsFromApi(Map<String, dynamic> meal) {
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(
          Ingredient(id: 0, name: '$ingredient ${measure ?? ''}'.trim()),
        );
      }
    }
    return ingredients;
  }
}
