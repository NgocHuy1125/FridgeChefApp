class Ingredient {
  String? id; // Primary Key
  String name;
  String? imageUrl; // image_url
  String? category; // category
  DateTime? createdAt; // created_at

  Ingredient({
    this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      imageUrl: map['image_url'],
      category: map['category'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}