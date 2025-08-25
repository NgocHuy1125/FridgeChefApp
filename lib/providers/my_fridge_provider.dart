import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import 'package:fridge_chef_app/main.dart';

enum FridgeView { fridge, suggestions }

class MyFridgeProvider extends ChangeNotifier {
  // --- STATE ---
  bool _isScreenLoading = true;
  bool get isScreenLoading => _isScreenLoading;

  final Set<String> _processingIngredients = {};
  bool isProcessing(String name) =>
      _processingIngredients.contains(name.toLowerCase());

  List<UserIngredient> _myFridgeItems = [];
  List<UserIngredient> get myFridgeItems => _myFridgeItems;

  List<Ingredient> _dbIngredients = []; // Danh sách đầy đủ từ DB
  List<String> _apiIngredientNames = []; // Danh sách đầy đủ từ API

  List<Ingredient> _quickSuggestIngredients = [];
  List<Ingredient> get quickSuggestIngredients => _quickSuggestIngredients;

  static const _pageSize = 30;
  int _currentPage = 0;
  bool _hasMoreIngredients = true;
  bool get hasMoreIngredients => _hasMoreIngredients;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

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
        _fetchAllDbIngredients(),
        _fetchAllApiIngredients(),
        fetchMoreIngredients(
          isInitialLoad: true,
        ), // Tải trang đầu của Gợi ý nhanh
      ]);
    } catch (e) {
      print("Initialization failed: $e");
    } finally {
      _isScreenLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _fetchAllDbIngredients() async {
    try {
      final response = await supabase.from('ingredients').select();
      _dbIngredients =
          response.map((item) => Ingredient.fromJson(item)).toList();
      _dbIngredients.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } catch (e) {
      print('Error fetching ALL DB ingredients: $e');
    }
  }

  Future<void> _fetchAllApiIngredients() async {
    final uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/list.php?i=list',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];
        _apiIngredientNames =
            meals
                .map<String>((json) => json['strIngredient'] as String)
                .toList();
        _apiIngredientNames.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
      }
    } catch (e) {
      print('Error fetching all API ingredients list: $e');
    }
  }

  // THÊM LẠI HÀM NÀY
  Future<void> fetchMoreIngredients({bool isInitialLoad = false}) async {
    if (_isLoadingMore || !_hasMoreIngredients) return;

    _isLoadingMore = true;
    if (!isInitialLoad) notifyListeners();

    try {
      final from = _currentPage * _pageSize;
      final to = from + _pageSize - 1;

      final response = await supabase
          .from('ingredients')
          .select()
          .order('name', ascending: true)
          .range(from, to);

      final newIngredients =
          response.map((item) => Ingredient.fromJson(item)).toList();

      if (isInitialLoad) {
        _quickSuggestIngredients.clear();
        _currentPage = 0;
        _hasMoreIngredients = true;
      }

      _quickSuggestIngredients.addAll(newIngredients);

      if (newIngredients.length < _pageSize) {
        _hasMoreIngredients = false;
      }

      _currentPage++;
    } catch (e) {
      print('Error fetching ingredients page: $e');
    } finally {
      _isLoadingMore = false;
      if (!_disposed) notifyListeners();
    }
  }

  List<Ingredient> getFilteredSuggestions(String query) {
    if (query.isEmpty) return [];

    final lowerCaseQuery = query.toLowerCase();
    final List<Ingredient> suggestions = [];
    final Set<String> addedNames = {};

    final dbMatches = _dbIngredients.where(
      (ing) => ing.name.toLowerCase().contains(lowerCaseQuery),
    );
    for (final ing in dbMatches) {
      if (addedNames.add(ing.name.toLowerCase())) {
        suggestions.add(ing);
      }
    }

    final apiMatches = _apiIngredientNames.where(
      (name) => name.toLowerCase().contains(lowerCaseQuery),
    );
    for (final name in apiMatches) {
      if (addedNames.add(name.toLowerCase())) {
        suggestions.add(Ingredient(id: 0, name: name));
      }
    }
    return suggestions.take(8).toList();
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
    _suggestedRecipes = [];
    notifyListeners();

    try {
      final userId = supabase.auth.currentUser!.id;
      final results = await Future.wait([
        _fetchRecipesFromSupabase(userId),
        _fetchRecipesFromApi(_myFridgeItems),
      ]);

      final List<Recipe> supabaseRecipes = results[0];
      final List<Recipe> apiRecipes = results[1];

      final Map<int, Recipe> combinedRecipes = {};
      for (final recipe in supabaseRecipes) {
        combinedRecipes[recipe.id] = recipe;
      }
      for (final recipe in apiRecipes) {
        if (!combinedRecipes.containsKey(recipe.id)) {
          combinedRecipes[recipe.id] = recipe;
        }
      }
      _suggestedRecipes = combinedRecipes.values.toList();
    } catch (e) {
      print('--- ERROR IN SHOW SUGGESTIONS VIEW ---: $e');
      _suggestedRecipes = [];
    } finally {
      _isSuggesting = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<List<Recipe>> _fetchRecipesFromSupabase(String userId) async {
    try {
      final rpcResponse = await supabase.rpc(
        'suggest_recipes',
        params: {'current_user_id': userId},
      );
      if (rpcResponse is List && rpcResponse.isNotEmpty) {
        final List<dynamic> recipeIds =
            rpcResponse.map((item) => item['recipe_id']).toList();
        if (recipeIds.isEmpty) return [];
        final detailedResponse = await supabase
            .from('recipes')
            .select('*, recipe_ingredients(*, ingredients(*))')
            .inFilter('id', recipeIds);
        final recipes =
            detailedResponse.map((item) => Recipe.fromJson(item)).toList();
        recipes.sort(
          (a, b) => recipeIds.indexOf(a.id).compareTo(recipeIds.indexOf(b.id)),
        );
        return recipes;
      }
      return [];
    } catch (e) {
      print("Error fetching from Supabase RPC: $e");
      return [];
    }
  }

  Future<List<Recipe>> _fetchRecipesFromApi(
    List<UserIngredient> ingredients,
  ) async {
    if (ingredients.isEmpty) return [];
    final primaryIngredient = ingredients.first.name;
    final uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?i=$primaryIngredient',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) return [];
        final List<dynamic> meals = data['meals'];
        final List<RecipeFromApi> apiRecipes =
            meals.map((json) => RecipeFromApi.fromJson(json)).toList();
        return apiRecipes
            .map((apiRecipe) => Recipe.fromApi(apiRecipe))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error fetching from TheMealDB API: $e");
      return [];
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
      final upsertResponse =
          await supabase
              .from('ingredients')
              .upsert({'name': ingredientName.trim()}, onConflict: 'name')
              .select('id')
              .single();
      final ingredientId = upsertResponse['id'];
      final userId = supabase.auth.currentUser!.id;
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
