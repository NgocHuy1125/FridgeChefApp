class Recipe {
  String? id; // Primary Key
  String name;
  String description;
  String instructions;
  String? imageUrl; // image_url
  int cookingTimeMinutes; // cooking_time_minutes
  String difficulty; // difficulty
  DateTime? createdAt; // created_at

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.instructions,
    this.imageUrl,
    required this.cookingTimeMinutes,
    required this.difficulty,
    this.createdAt,
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
    );
  }
}