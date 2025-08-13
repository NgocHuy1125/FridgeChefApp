class UserIngredient {
  String? userId; // user_id (FK to UserProfile)
  String? ingredientId; // ingredient_id (FK to Ingredient)
  DateTime? addedAt; // added_at

  UserIngredient({
    this.userId,
    this.ingredientId,
    this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'ingredient_id': ingredientId,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  factory UserIngredient.fromMap(Map<String, dynamic> map) {
    return UserIngredient(
      userId: map['user_id'],
      ingredientId: map['ingredient_id'],
      addedAt: map['added_at'] != null ? DateTime.parse(map['added_at']) : null,
    );
  }
}