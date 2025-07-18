class UserActivity {
  String? id; // Primary Key
  String? userId; // user_id (FK to UserProfile)
  String activity; // activity (e.g., 'login', 'logout', 'updated_profile')
  DateTime? createdAt; // created_at

  UserActivity({
    this.id,
    this.userId,
    required this.activity,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity': activity,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      id: map['id'],
      userId: map['user_id'],
      activity: map['activity'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}