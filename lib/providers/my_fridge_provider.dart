import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';
import '../services/meal_api.dart';

enum FridgeView { fridge, suggestions }

class MyFridgeProvider extends ChangeNotifier {
  final MealDbApiService _apiService = MealDbApiService();

  // --- STATE ---
  bool _isScreenLoading = true;
  bool get isScreenLoading => _isScreenLoading;

  final Set<String> _processingIngredients = {};
  bool isProcessing(String name) =>
      _processingIngredients.contains(name.toLowerCase());

  List<UserIngredient> _myFridgeItems = [];
  List<UserIngredient> get myFridgeItems => _myFridgeItems;

  List<Ingredient> _popularDbIngredients = [];
  List<Ingredient> get popularDbIngredients => _popularDbIngredients;

  // === STATE MỚI CHO GIAO DIỆN ===
  FridgeView _currentView = FridgeView.fridge;
  FridgeView get currentView => _currentView;

  List<Recipe> _suggestedRecipes = [];
  List<Recipe> get suggestedRecipes => _suggestedRecipes;

  bool _isSuggesting = false;
  bool get isSuggesting => _isSuggesting;

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

  // --- LOGIC ---

  Future<void> initialize() async {
    _isScreenLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchMyFridgeItems(notify: false),
        _fetchPopularDbIngredients(),
      ]);
    } catch (e) {
      print("Initialization failed: $e");
    } finally {
      _isScreenLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void showFridgeView() {
    if (_currentView != FridgeView.fridge) {
      _currentView = FridgeView.fridge;
      notifyListeners();
    }
  }

  Future<void> showSuggestionsView() async {
    if (_myFridgeItems.isEmpty) return;

    _isSuggesting = true;
    _currentView = FridgeView.suggestions;
    notifyListeners();

    try {
      final userId = supabase.auth.currentUser!.id;
      final rpcResponse = await supabase.rpc(
        'suggest_recipes',
        params: {'current_user_id': userId},
      );

      if (rpcResponse is List && rpcResponse.isNotEmpty) {
        final List<dynamic> recipeIds =
            rpcResponse.map((item) => item['recipe_id']).toList();
        if (recipeIds.isEmpty) {
          _suggestedRecipes = [];
        } else {
          final detailedResponse = await supabase
              .from('recipes')
              .select('*, recipe_ingredients(*, ingredients(*))')
              .inFilter('id', recipeIds); // Dùng inFilter

          final recipes =
              detailedResponse.map((item) => Recipe.fromJson(item)).toList();
          recipes.sort(
            (a, b) =>
                recipeIds.indexOf(a.id).compareTo(recipeIds.indexOf(b.id)),
          );
          _suggestedRecipes = recipes;
        }
      } else {
        _suggestedRecipes = [];
      }
    } catch (e) {
      print('--- ERROR SUGGESTING RECIPES ---: $e');
      _suggestedRecipes = [];
    } finally {
      _isSuggesting = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> fetchMyFridgeItems({bool notify = true}) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('user_ingredients')
          .select('*, ingredients (*)')
          .eq('user_id', userId)
          .order('added_at', ascending: false);
      _myFridgeItems =
          response.map((item) => UserIngredient.fromSupabase(item)).toList();
    } catch (e) {
      print('--- ERROR fetching fridge items: $e');
    }
    if (notify && !_disposed) notifyListeners();
  }

  Future<void> _fetchPopularDbIngredients() async {
    try {
      final response = await supabase.from('ingredients').select().limit(15);
      _popularDbIngredients =
          response.map((item) => Ingredient.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching popular DB ingredients: $e');
    }
  }

  Future<void> toggleIngredientInFridge(String ingredientName) async {
    final trimmedName = ingredientName.trim();
    if (trimmedName.isEmpty) return;

    final lowerCaseName = trimmedName.toLowerCase();

    _processingIngredients.add(lowerCaseName);
    notifyListeners();

    try {
      final existingItem = _myFridgeItems.firstWhere(
        (item) => item.name.toLowerCase() == lowerCaseName,
        orElse: () => UserIngredient.empty(),
      );

      if (existingItem.isNotEmpty) {
        await removeIngredientFromFridge(existingItem.ingredientId);
      } else {
        await addIngredientToFridge(trimmedName);
      }
    } catch (e) {
      print('Error toggling ingredient: $e');
      await fetchMyFridgeItems(notify: false);
    } finally {
      _processingIngredients.remove(lowerCaseName);
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> addIngredientToFridge(String ingredientName) async {
    final lowerCaseName = ingredientName.trim().toLowerCase();
    if (_myFridgeItems.any((item) => item.name.toLowerCase() == lowerCaseName))
      return;

    try {
      await supabase
          .from('ingredients')
          .upsert({'name': ingredientName.trim()}, onConflict: 'name')
          .select('id')
          .single();

      final userId = supabase.auth.currentUser!.id;
      final ingredient =
          await supabase
              .from('ingredients')
              .select('id')
              .eq('name', ingredientName.trim())
              .single();
      final ingredientId = ingredient['id'];

      await supabase.from('user_ingredients').insert({
        'user_id': userId,
        'ingredient_id': ingredientId,
      });

      await fetchMyFridgeItems(notify: false);
    } catch (e) {
      print('Error adding ingredient: $e');
      throw Exception('Failed to add ingredient');
    }
  }

  Future<void> removeIngredientFromFridge(int ingredientId) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('user_ingredients').delete().match({
        'user_id': userId,
        'ingredient_id': ingredientId,
      });
      await fetchMyFridgeItems(notify: false);
    } catch (e) {
      print('Error removing ingredient: $e');
      throw Exception('Failed to remove ingredient');
    }
  }
}
