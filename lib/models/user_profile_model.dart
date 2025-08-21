class UserProfile {
  final String id; // Luôn là String (UUID)
  final String? username;
  final String? avatarUrl;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.username,
    this.avatarUrl,
    this.updatedAt,
  });

  // Chuyển đổi một đối tượng Map (từ Supabase) thành đối tượng UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'avatar_url': avatarUrl};
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
