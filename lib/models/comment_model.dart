import '/models/user_profile_model.dart';

class Comment {
  final int id;
  final String userId;
  final int recipeId;
  final String content;
  final DateTime createdAt;

  // 2. SỬA LẠI TÊN CLASS Ở ĐÂY
  final UserProfile? author;

  Comment({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at']),

      // VÀ SỬA LẠI TÊN CLASS Ở ĐÂY
      author:
          json['profiles'] != null
              ? UserProfile.fromJson(json['profiles'])
              : null,
    );
  }
}
