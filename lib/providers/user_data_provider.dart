import 'package:flutter/material.dart';
import 'package:fridge_chef_app/screens/login_screen.dart';
import '/models/recipe_model.dart';
import '/models/user_profile_model.dart';
import 'package:fridge_chef_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDataProvider extends ChangeNotifier {
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

  // === STATE ===
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  int _viewedCount = 0;
  int get viewedCount => _viewedCount;

  int _cookedCount = 0;
  int get cookedCount => _cookedCount;

  int _favoriteCount = 0;
  int get favoriteCount => _favoriteCount;

  List<Recipe> _viewedHistory = [];
  List<Recipe> get viewedHistory => _viewedHistory;

  List<Recipe> _favoriteRecipes = [];
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  List<Recipe> _cookedHistory = [];
  List<Recipe> get cookedHistory => _cookedHistory;

  Set<int> _favoriteRecipeIds = {};
  Set<int> get favoriteRecipeIds => _favoriteRecipeIds;

  Future<void> loadAllUserData() async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User is not logged in");

      final responses = await Future.wait([
        supabase.from('profiles').select().eq('id', userId).single(),
        supabase
            .from('view_history')
            .select('recipes(*)')
            .eq('user_id', userId)
            .order('last_viewed_at', ascending: false)
            .limit(5),
        supabase
            .from('user_favorites')
            .select('recipes(*)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(5),
        supabase
            .from('cooking_history')
            .select('recipes(*)')
            .eq('user_id', userId)
            .order('cooked_at', ascending: false)
            .limit(5),
        supabase.from('cooking_history').select('id').eq('user_id', userId),
        supabase
            .from('user_favorites')
            .select('recipe_id')
            .eq('user_id', userId),
        supabase.from('view_history').select('recipe_id').eq('user_id', userId),
      ]);

      _userProfile = UserProfile.fromJson(responses[0] as Map<String, dynamic>);

      final viewedData = responses[1] as List;
      _viewedHistory =
          viewedData
              .where((item) => item['recipes'] != null)
              .map((item) => Recipe.fromJson(item['recipes']))
              .toList();

      final favoriteData = responses[2] as List;
      _favoriteRecipes =
          favoriteData
              .where((item) => item['recipes'] != null)
              .map((item) => Recipe.fromJson(item['recipes']))
              .toList();

      final cookedData = responses[3] as List;
      _cookedHistory =
          cookedData
              .where((item) => item['recipes'] != null)
              .map((item) => Recipe.fromJson(item['recipes']))
              .toList();

      final cookedResponse = responses[4] as List;
      _cookedCount = cookedResponse.length;

      final favoriteResponse = responses[5] as List;
      _favoriteCount = favoriteResponse.length;
      _favoriteRecipeIds =
          favoriteResponse.map<int>((item) => item['recipe_id'] as int).toSet();

      final viewedResponse = responses[6] as List;
      _viewedCount = viewedResponse.length;
    } catch (e) {
      print('Error loading all user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final recipeId = recipe.id;
    final currentlyFavorite = isFavorite(recipeId);

    if (currentlyFavorite) {
      _favoriteRecipeIds.remove(recipeId);
      _favoriteRecipes.removeWhere((r) => r.id == recipeId);
      _favoriteCount--;
    } else {
      _favoriteRecipeIds.add(recipeId);
      _favoriteRecipes.insert(0, recipe);
      _favoriteCount++;
    }
    notifyListeners();

    try {
      await supabase.from('recipes').upsert({
        'id': recipeId,
        'name': recipe.name,
        'image_url': recipe.imageUrl,
        'instructions': recipe.instructions,
        'youtube_url': recipe.youtubeUrl,
      }, onConflict: 'id');

      if (currentlyFavorite) {
        await supabase.from('user_favorites').delete().match({
          'user_id': userId,
          'recipe_id': recipeId,
        });
      } else {
        await supabase.from('user_favorites').insert({
          'user_id': userId,
          'recipe_id': recipeId,
        });
      }
    } catch (e) {
      print('Error toggling favorite on server: $e');
      await loadAllUserData();
    }
  }

  // *** HÀM ADDVIEWHISTORY ĐÃ ĐƯỢC VIẾT LẠI HOÀN CHỈNH ***
  Future<void> addViewToHistory(int recipeId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final existingRecord =
          await supabase.from('view_history').select('user_id').match({
            'user_id': userId,
            'recipe_id': recipeId,
          }).maybeSingle();

      bool isNewView = (existingRecord == null);

      final now = DateTime.now().toIso8601String();
      if (isNewView) {
        await supabase.from('view_history').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'last_viewed_at': now,
        });
      } else {
        await supabase
            .from('view_history')
            .update({'last_viewed_at': now})
            .match({'user_id': userId, 'recipe_id': recipeId});
      }

      if (isNewView) {
        _viewedCount++;
      }

      final viewedDataResponse = await supabase
          .from('view_history')
          .select('recipes(*)')
          .eq('user_id', userId)
          .order('last_viewed_at', ascending: false)
          .limit(5);

      _viewedHistory =
          viewedDataResponse
              .where((item) => item['recipes'] != null)
              .map((item) => Recipe.fromJson(item['recipes']))
              .toList();

      notifyListeners();

      print('Successfully updated view history for recipe $recipeId');
    } catch (e) {
      print('Error adding view to history: $e');

      await loadAllUserData();
    }
  }

  Future<void> addCookingToHistory(int recipeId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase.from('cooking_history').insert({
        'user_id': userId,
        'recipe_id': recipeId,
        'cooked_at': DateTime.now().toIso8601String(),
      });
      print('Added cooking history for recipe $recipeId');
      await loadAllUserData();
    } catch (e) {
      print('Error adding cooking to history: $e');
    }
  }

  bool isFavorite(int recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  Future<void> signOut(BuildContext context) async {
    await supabase.auth.signOut();
    _userProfile = null;
    _favoriteRecipeIds.clear();
    _favoriteRecipes.clear();
    _viewedHistory.clear();
    _cookedHistory.clear();
    _viewedCount = 0;
    _cookedCount = 0;
    _favoriteCount = 0;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
