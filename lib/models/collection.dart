class Collection {
  String? id; // Primary Key
  String? userId; // user_id (FK to UserProfile)
  String name; // name
  String? description; // description
  DateTime? createdAt; // created_at

  Collection({
    this.id,
    this.userId,
    required this.name,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}