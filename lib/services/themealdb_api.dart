import 'dart:convert';
import 'package:http/http.dart' as http;

class TheMealDBApi {
  static Future<Map<String, dynamic>?> fetchMealDetailById(String id) async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return data['meals'][0];
      }
    }
    return null;
  }
}
