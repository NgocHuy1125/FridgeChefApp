class RecipeDetail {
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final String instructions;
  final List<String> ingredients;

  RecipeDetail({
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.instructions,
    required this.ingredients,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      title: json['title'],
      image: json['image'],
      readyInMinutes: json['readyInMinutes'],
      servings: json['servings'],
      instructions: json['instructions'] ?? 'Không có hướng dẫn.',
      ingredients:
          (json['extendedIngredients'] as List)
              .map((e) => e['original'] as String)
              .toList(),
    );
  }
}
