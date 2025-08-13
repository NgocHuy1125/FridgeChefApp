class CookingHistory {
  String? id; // Primary Key
  String? userId; // user_id (FK to UserProfile)
  String? recipeId; // recipe_id (FK to Recipe)
  int? rating; // rating
  String? notes; // notes
  DateTime? cookedAt; // cooked_at

  CookingHistory({
    this.id,
    this.userId,
    this.recipeId,
    this.rating,
    this.notes,
    this.cookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'notes': notes,
      'cooked_at': cookedAt?.toIso8601String(),
    };
  }

  factory CookingHistory.fromMap(Map<String, dynamic> map) {
    return CookingHistory(
      id: map['id'],
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      rating: map['rating'],
      notes: map['notes'],
      cookedAt: map['cooked_at'] != null ? DateTime.parse(map['cooked_at']) : null,
    );
  }
}