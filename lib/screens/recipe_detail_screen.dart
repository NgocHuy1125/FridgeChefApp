import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;

  RecipeDetailScreen({required this.mealId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isFavorite = false;
  bool isViewed = false;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail();
  }

  Future<void> fetchRecipeDetail() async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipe = data['meals'][0];
        // Giả định mặc định là chưa lưu. Sau này tích hợp Supabase sẽ đọc dữ liệu thật.
        isViewed = true; // Khi xem là lưu vào lịch sử luôn
      });
    }
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      // TODO: Lưu vào Supabase
    });
  }

  void saveViewed() {
    setState(() {
      isViewed = true;
      // TODO: Ghi log lịch sử xem lên Supabase
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết món ăn')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe!['strMeal']),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              color: isViewed ? Colors.yellow : Colors.white,
            ),
            onPressed: saveViewed,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe!['strMealThumb']),
            SizedBox(height: 16),
            Text(
              recipe!['strMeal'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Danh mục: ${recipe!['strCategory'] ?? ''}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Hướng dẫn:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(recipe!['strInstructions'] ?? ''),
            SizedBox(height: 16),
            Text(
              'Nguyên liệu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            ...getIngredients(),
          ],
        ),
      ),
    );
  }

  List<Widget> getIngredients() {
    List<Widget> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = recipe!['strIngredient$i'];
      final measure = recipe!['strMeasure$i'];
      if (ingredient != null && ingredient.toString().isNotEmpty) {
        ingredients.add(Text('- $ingredient: $measure'));
      }
    }
    return ingredients;
  }
}
