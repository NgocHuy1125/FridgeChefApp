import 'dart:convert';
import 'package:fridge_chef_app/services/api_constants.dart';
import 'package:http/http.dart' as http;
import '/models/recipe_model.dart';

class MealDbApiService {
  static const String supabaseUrl = 'https://myewzpkzeeikxgxutvmb.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15ZXd6cGt6ZWVpa3hneHV0dm1iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxMzI4MzQsImV4cCI6MjA2NzcwODgzNH0.ASqYk9EH0LwrchS5fzNey3_FzDbaS2sCIvCng0uO-iQ';
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Gọi dữ liệu từ Supabase
  Future<List<RecipeFromApi>> fetchRecipesFromSupabase(String keyword) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/recipes?name=ilike.*$keyword*&select=*'),
      headers: {'apikey': supabaseKey, 'Authorization': 'Bearer $supabaseKey'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => RecipeFromApi.fromJson(json)).toList();
    }
    return [];
  }

  // Gọi dữ liệu từ TheMealDB
  Future<List<RecipeFromApi>> fetchRecipesFromMealDB(String keyword) async {
    final response = await http.get(
      Uri.parse('$mealDbBaseUrl/search.php?s=$keyword'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((json) => RecipeFromApi.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  // Kết hợp cả hai nguồn
  Future<List<RecipeFromApi>> searchAllSources(String keyword) async {
    final supabaseFuture = fetchRecipesFromSupabase(keyword);
    final mealDbFuture = fetchRecipesFromMealDB(keyword);

    final [supabaseResults, mealDbResults] = await Future.wait([
      supabaseFuture,
      mealDbFuture,
    ]);

    final Map<String, RecipeFromApi> uniqueResults = {};
    for (var result in supabaseResults) {
      uniqueResults[result.id] = result;
    }
    for (var result in mealDbResults) {
      uniqueResults[result.id] = result;
    }
    return uniqueResults.values.toList();
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

  Future<List<RecipeFromApi>> fetchRecipesByCategory(String category) async {
    final uri = Uri.parse(
      '$mealDbBaseUrl/filter.php?c=${Uri.encodeComponent(category)}',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map(
              (json) => RecipeFromApi.fromJson({
                'idMeal': json['idMeal'],
                'strMeal': json['strMeal'],
                'strMealThumb': json['strMealThumb'],
              }),
            )
            .toList();
      }
    }
    return [];
  }
}
