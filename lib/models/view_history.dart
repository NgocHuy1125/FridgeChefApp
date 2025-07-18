class ViewHistory {
  String? userId; // user_id (FK to UserProfile)
  String? recipeId; // recipe_id (FK to Recipe)
  DateTime? lastViewedAt; // last_viewed_at

  ViewHistory({
    this.userId,
    this.recipeId,
    this.lastViewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'recipe_id': recipeId,
      'last_viewed_at': lastViewedAt?.toIso8601String(),
    };
  }

  factory ViewHistory.fromMap(Map<String, dynamic> map) {
    return ViewHistory(
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      lastViewedAt: map['last_viewed_at'] != null ? DateTime.parse(map['last_viewed_at']) : null,
    );
  }
}