import 'package:flutter/material.dart';
import 'package:fridge_chef_app/services/themealdb_api.dart';
import '../services/supabase_service.dart'; // Đổi lại file API
import '../utils/storage_helper.dart';
import 'recipe_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await StorageHelper.getStringList('favorites');
    List<Map<String, dynamic>> result = [];

    for (var id in ids) {
      final meal = await TheMealDBApi.fetchMealDetailById(id);
      if (meal != null) result.add(meal);
    }

    setState(() {
      favoriteRecipes = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Món Yêu Thích")),
      body:
          favoriteRecipes.isEmpty
              ? Center(child: Text("Chưa có món nào được lưu."))
              : ListView.builder(
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];
                  return ListTile(
                    leading: Image.network(recipe['strMealThumb']),
                    title: Text(recipe['strMeal']),
                    subtitle: Text("ID: ${recipe['idMeal']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  RecipeDetailScreen(mealId: recipe['idMeal']),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
