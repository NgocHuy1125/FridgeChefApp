class UserProfile {
  String? id; // auth.users_id
  String username;
  String? avatarUrl;
  String? email; // Thêm cột email nếu muốn
  DateTime? createdAt; // created_at
  DateTime? updatedAt; // updated_at

  UserProfile({
    this.id,
    required this.username,
    this.avatarUrl,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      username: map['username'],
      avatarUrl: map['avatar_url'],
      email: map['email'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}