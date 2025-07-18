class UserFavorite {
  String? userId; // user_id (FK to UserProfile)
  String? recipeId; // recipe_id (FK to Recipe)
  DateTime? createdAt; // created_at

  UserFavorite({
    this.userId,
    this.recipeId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'recipe_id': recipeId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserFavorite.fromMap(Map<String, dynamic> map) {
    return UserFavorite(
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}