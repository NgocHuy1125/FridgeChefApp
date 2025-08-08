import 'package:supabase_flutter/supabase_flutter.dart';

import '/models/comment_model.dart';
import '/models/ingredient_model.dart';
import '/models/tag_model.dart';
import '/models/user_profile_model.dart';

class Recipe {
  final int id;
  final String name;
  final String? instructions;
  final String? imageUrl;

  final List<Ingredient> ingredients;
  final List<Tag> tags;
  final List<Comment> comments;

  Recipe({
    required this.id,
    required this.name,
    this.instructions,
    this.imageUrl,
    this.ingredients = const [],
    this.tags = const [],
    this.comments = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
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
      'id': id,
      'name': name,
      'instructions': instructions,
      'image_url': imageUrl,
      'ingredients': ingredients
          .map((e) => {
                'name': e.name,
              })
          .toList(),
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
      id: json['idMeal']?.toString() ?? json['id']?.toString() ?? '0',
      name: json['strMeal'] ?? json['name'] ?? 'Không rõ',
      imageUrl: json['strMealThumb'] ?? json['image_url'] ?? '',
      instructions: json['strInstructions'] ?? json['instructions'] ?? '',
    );
  }
}
