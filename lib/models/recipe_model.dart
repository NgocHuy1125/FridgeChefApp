import '/models/comment_model.dart';
import '/models/ingredient_model.dart';
import '/models/tag_model.dart';
import '/models/user_profile_model.dart';

class Recipe {
  final int id;
  final String name;
  final String? description;
  final String? instructions;
  final String? imageUrl;
  final int? cookingTimeMinutes;
  final String? difficulty;
  final DateTime? createdAt;

  final List<Ingredient> ingredients;
  final List<Tag> tags;
  final List<Comment> comments;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    this.imageUrl,
    this.cookingTimeMinutes,
    this.difficulty,
    this.createdAt,
    this.ingredients = const [],
    this.tags = const [],
    this.comments = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      cookingTimeMinutes: json['cooking_time_minutes'],
      difficulty: json['difficulty'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      ingredients:
          (json['ingredients'] as List?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      tags: (json['tags'] as List?)?.map((e) => Tag.fromJson(e)).toList() ?? [],
      comments:
          (json['comments'] as List?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'cooking_time_minutes': cookingTimeMinutes,
      'difficulty': difficulty,
    };
  }
}

class RecipeFromApi {
  final String id;
  final String name;
  final String imageUrl;
  final String? instructions;

  RecipeFromApi({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.instructions,
  });

  factory RecipeFromApi.fromJson(Map<String, dynamic> json) {
    return RecipeFromApi(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
      instructions: json['strInstructions'],
    );
  }
}
