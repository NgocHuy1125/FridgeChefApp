// lib/models/recipe_model.dart

import '/models/comment_model.dart';
import '/models/ingredient_model.dart';
import '/models/tag_model.dart';

// Class Recipe đã được sửa lại factory FromJson
class Recipe {
  final int id;
  final String name;
  final String? instructions;
  final String? imageUrl;
  final String? youtubeUrl;
  final int? cookingTimeMinutes;
  final String? difficulty;

  final List<Ingredient> ingredients;
  final List<Tag> tags;
  final List<Comment> comments;

  Recipe({
    required this.id,
    required this.name,
    this.instructions,
    this.imageUrl,
    this.youtubeUrl,
    this.ingredients = const [],
    this.tags = const [],
    this.comments = const [],
    this.cookingTimeMinutes,
    this.difficulty,
  });
  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsList = <Ingredient>[];
    if (json['recipe_ingredients'] != null &&
        json['recipe_ingredients'] is List) {
      ingredientsList =
          (json['recipe_ingredients'] as List)
              .where((item) => item['ingredients'] != null)
              .map((item) => Ingredient.fromJson(item['ingredients']))
              .toList();
    }

    return Recipe(
      id: json['id'],
      name: json['name'] ?? 'Không có tên',
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      youtubeUrl: json['youtube_url'],
      cookingTimeMinutes: json['cooking_time_minutes'],
      difficulty: json['difficulty'],
      ingredients: ingredientsList,
      tags: (json['tags'] as List?)?.map((e) => Tag.fromJson(e)).toList() ?? [],
      comments:
          (json['comments'] as List?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory Recipe.fromApi(RecipeFromApi apiRecipe) {
    return Recipe(
      id: int.tryParse(apiRecipe.id) ?? 0,
      name: apiRecipe.name,
      imageUrl: apiRecipe.imageUrl,
      instructions: apiRecipe.instructions,
      youtubeUrl: apiRecipe.youtubeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'image_url': imageUrl,
      'youtube_url': youtubeUrl,
      'ingredients': ingredients.map((e) => {'name': e.name}).toList(),
    };
  }

  Recipe copyWith({List<Ingredient>? ingredients}) {
    return Recipe(
      id: id,
      name: name,
      instructions: instructions,
      imageUrl: imageUrl,
      youtubeUrl: youtubeUrl,
      cookingTimeMinutes: cookingTimeMinutes,
      difficulty: difficulty,
      ingredients: ingredients ?? this.ingredients,
      tags: tags,
      comments: comments,
    );
  }
}

class RecipeFromApi {
  final String id;
  final String name;
  final String imageUrl;
  final String? instructions;
  final String? youtubeUrl;

  RecipeFromApi({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.instructions,
    this.youtubeUrl,
  });

  factory RecipeFromApi.fromJson(Map<String, dynamic> json) {
    return RecipeFromApi(
      id: json['idMeal']?.toString() ?? json['id']?.toString() ?? '0',
      name: json['strMeal'] ?? json['name'] ?? 'Không rõ',
      imageUrl: json['strMealThumb'] ?? json['image_url'] ?? '',
      instructions: json['strInstructions'] ?? json['instructions'] ?? '',
      youtubeUrl: json['strYoutube'],
    );
  }
}
