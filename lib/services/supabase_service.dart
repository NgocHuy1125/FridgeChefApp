import 'dart:convert';
import 'package:http/http.dart' as http;

class MealDBApi {
  static const String baseUrl = "https://www.themealdb.com/api/json/v1/1";

  // Lấy danh sách danh mục món ăn
  static Future<List<String>> fetchCategories() async {
    final url = Uri.parse("$baseUrl/list.php?c=list");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['meals'] as List)
          .map<String>((e) => e['strCategory'] as String)
          .toList();
    } else {
      throw Exception("Lỗi khi tải danh mục món ăn");
    }
  }

  // Lấy món ăn theo danh mục
  static Future<List<Map<String, dynamic>>> fetchMealsByCategory(
    String category,
  ) async {
    final url = Uri.parse("$baseUrl/filter.php?c=$category");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['meals'] as List)
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception("Lỗi khi tải món ăn theo danh mục");
    }
  }

  // Lấy món ăn theo nguyên liệu (ingredient)
  static Future<List<Map<String, dynamic>>> fetchMealsByIngredient(
    String ingredient,
  ) async {
    final url = Uri.parse("$baseUrl/filter.php?i=$ingredient");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['meals'] as List)
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      return []; // không tìm thấy cũng trả về rỗng
    }
  }

  // Lấy chi tiết món ăn theo id
  static Future<Map<String, dynamic>> fetchMealDetail(String idMeal) async {
    final url = Uri.parse("$baseUrl/lookup.php?i=$idMeal");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'][0];
    } else {
      throw Exception("Lỗi khi tải chi tiết món ăn");
    }
  }
  
}
