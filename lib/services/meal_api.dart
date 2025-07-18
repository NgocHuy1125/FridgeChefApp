// services/mealdb_api.dart
import 'dart:convert';
import 'package:fridge_chef_app/models/recipe.dart';
import 'package:http/http.dart' as http;

class MealDBApi {
  static Future<List<Meal>> searchMeals(String keyword) async {
    final url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=$keyword';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((e) => Meal.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load meals');
    }
  }
}
