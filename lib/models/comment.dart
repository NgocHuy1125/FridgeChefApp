class Comment {
  String? id; // Primary Key
  String? userId; // user_id (FK to UserProfile)
  String? recipeId; // recipe_id (FK to Recipe)
  String content; // content
  DateTime? createdAt; // created_at

  Comment({
    this.id,
    this.userId,
    this.recipeId,
    required this.content,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      content: map['content'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}