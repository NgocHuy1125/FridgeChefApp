class Category {
  final String id;
  final String name;
  final String? thumbnail;

  Category({required this.id, required this.name, this.thumbnail});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory']?.toString() ?? '0',
      name: json['strCategory'] ?? 'Unknown',
      thumbnail: json['strCategoryThumb'],
    );
  }

  factory Category.fromSupabaseJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'Unknown',
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnail,
    };
  }
}
