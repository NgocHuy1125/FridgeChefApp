class Ingredient {
  final int id;
  final String name;
  final String? category;

  Ingredient({required this.id, required this.name, this.category});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] ?? 'Không rõ',
      category: json['category'],
    );
  }
}

class UserIngredient {
  final String userId;
  final int ingredientId;
  final DateTime addedAt;

  // Thông tin từ bảng ingredients (sau khi JOIN)
  final String name;
  final String? category;
  final String? imageUrl;

  UserIngredient({
    required this.userId,
    required this.ingredientId,
    required this.addedAt,
    required this.name,
    this.category,
    this.imageUrl,
  });

  factory UserIngredient.fromSupabase(Map<String, dynamic> data) {
    // Dữ liệu 'ingredients' là một object lồng vào từ JOIN
    final ingredientData = data['ingredients'] as Map<String, dynamic>? ?? {};

    return UserIngredient(
      userId: data['user_id'],
      ingredientId: data['ingredient_id'],
      addedAt: DateTime.parse(data['added_at']),
      name: ingredientData['name'] ?? 'Không rõ',
      category: ingredientData['category'],
      imageUrl: ingredientData['image_url'],
    );
  }
}
