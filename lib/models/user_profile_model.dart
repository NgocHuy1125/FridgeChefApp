class UserProfile {
  final String id; // Luôn là String (UUID)
  final String? username;
  final String? avatarUrl;
  final DateTime? updatedAt;
  // Bỏ email vì nó đã có trong đối tượng User của Supabase Auth
  // Bỏ createdAt vì thường không cần hiển thị

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

  // Chuyển đổi một đối tượng UserProfile thành Map để gửi lên Supabase
  // Hữu ích cho việc UPDATE profile
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      // `updated_at` thường được DB tự động cập nhật
    };
  }

  // (Tùy chọn) Hàm copyWith để dễ dàng tạo bản sao và cập nhật trạng thái
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
