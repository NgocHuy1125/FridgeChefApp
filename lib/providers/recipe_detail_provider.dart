import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';

enum DetailStatus { loading, success, error }

class RecipeDetailProvider extends ChangeNotifier {
  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  DetailStatus _status = DetailStatus.loading;
  DetailStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // State mới để theo dõi tiến độ nấu ăn
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

  // Hàm đánh dấu/bỏ đánh dấu một bước
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
      final response =
          await supabase
              .from('recipes')
              .select('*, recipe_ingredients(*, ingredients(*))')
              .eq('id', recipeId)
              .single();
      _recipe = Recipe.fromJson(response);
      _status = DetailStatus.success;
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage = 'Không thể tải dữ liệu món ăn.';
      print('Error fetching recipe details: $e');
    } finally {
      notifyListeners();
    }
  }
}
