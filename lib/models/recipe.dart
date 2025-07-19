// lib/models/recipe.dart
class Recipe {
  final String? id;
  final String name;
  final String description;
  final String instructions;
  final String? imageUrl;
  final int cookingTimeMinutes;
  final String difficulty;
  final DateTime? createdAt;
  final List<String>? requiredIngredientIds; // <-- THÊM DÒNG NÀY

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.instructions,
    this.imageUrl,
    required this.cookingTimeMinutes,
    required this.difficulty,
    this.createdAt,
    this.requiredIngredientIds, // <-- THÊM DÒNG NÀY
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'cooking_time_minutes': cookingTimeMinutes,
      'difficulty': difficulty,
      'created_at': createdAt?.toIso8601String(),
      'required_ingredient_ids': requiredIngredientIds?.join(','), // Chuyển List<String> thành String
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      instructions: map['instructions'],
      imageUrl: map['image_url'],
      cookingTimeMinutes: map['cooking_time_minutes'],
      difficulty: map['difficulty'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      requiredIngredientIds: map['required_ingredient_ids'] != null
          ? (map['required_ingredient_ids'] as String).split(',') // Chuyển String thành List<String>
          : null,
    );
  }
}