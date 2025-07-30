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

  List<String> _allApiIngredientNamesForSearch = [];

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
    if (!_disposed) {
      super.notifyListeners();
    }
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
      notifyListeners();
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
      final ingredientNames = _myFridgeItems.map((item) => item.name).toList();
      final recipes = await _apiService.suggestRecipes(ingredientNames);
      _suggestedRecipes = recipes.cast<Recipe>();
    } catch (e) {
      print('Error suggesting recipes from MealDB: $e');
      _suggestedRecipes = [];
    } finally {
      _isSuggesting = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyFridgeItems({bool notify = true}) async {
    final userId = supabase.auth.currentUser!.id;
    try {
      final response = await supabase
          .from('user_ingredients')
          .select('*, ingredients (*)')
          .eq('user_id', userId)
          .order('added_at');
      _myFridgeItems =
          response.map((item) => UserIngredient.fromSupabase(item)).toList();
    } catch (e) {
      print('Error fetching fridge items: $e');
    }
    if (notify) notifyListeners();
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

  Future<void> _fetchAllIngredientsFromApiForSearch() async {
    try {
      _allApiIngredientNamesForSearch =
          await _apiService.getAllIngredientNames();
    } catch (e) {
      print('Error fetching all API ingredients for search: $e');
    }
  }

  List<Ingredient> getFilteredSuggestions(String query) {
    if (query.isEmpty) return [];
    return _allApiIngredientNamesForSearch
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .map((name) => Ingredient(id: 0, name: name))
        .take(5)
        .toList();
  }

  Future<void> toggleIngredientInFridge(String ingredientName) async {
    final trimmedName = ingredientName.trim();
    final lowerCaseName = trimmedName.toLowerCase();

    _processingIngredients.add(lowerCaseName);
    notifyListeners();

    try {
      final existingItem = _myFridgeItems.firstWhere(
        (item) => item.name.toLowerCase() == lowerCaseName,
        orElse:
            () => UserIngredient(
              userId: '',
              ingredientId: -1,
              addedAt: DateTime.now(),
              name: '',
            ),
      );
      
      if (existingItem.ingredientId != -1) {
        await removeIngredientFromFridge(existingItem.ingredientId);
      } else {
        await addIngredientToFridge(trimmedName);
        if (_currentView == FridgeView.suggestions) {
          await showSuggestionsView();
        }
      }
    } catch (e) {
      print('Error toggling ingredient: $e');
      await fetchMyFridgeItems();
    } finally {
      _processingIngredients.remove(lowerCaseName);
      notifyListeners();
    }
  }

  Future<void> addIngredientToFridge(String ingredientName) async {
    final lowerCaseName = ingredientName.trim().toLowerCase();
    if (_myFridgeItems.any((item) => item.name.toLowerCase() == lowerCaseName))
      return;

    _processingIngredients.add(lowerCaseName);
    notifyListeners();

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
        'quantity': 1, // Thêm số lượng mặc định là 1
      });
      await fetchMyFridgeItems(notify: false);
    } catch (e) {
      print('Error adding ingredient: $e');
    } finally {
      _processingIngredients.remove(lowerCaseName);
      notifyListeners();
    }
  }

  Future<void> removeIngredientFromFridge(int ingredientId) async {
    final itemToRemove = _myFridgeItems.firstWhere(
      (item) => item.ingredientId == ingredientId,
      orElse:
          () => UserIngredient(
            userId: '',
            ingredientId: -1,
            addedAt: DateTime.now(),
            name: '',
            
          ),
    );
    if (itemToRemove.ingredientId == -1) return;

    _processingIngredients.add(itemToRemove.name.toLowerCase());
    notifyListeners();

    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('user_ingredients').delete().match({
        'user_id': userId,
        'ingredient_id': ingredientId,
      });
      await fetchMyFridgeItems(notify: false);
    } catch (e) {
      print('Error removing ingredient: $e');
    } finally {
      _processingIngredients.remove(itemToRemove.name.toLowerCase());
      notifyListeners();
    }
  }
}
