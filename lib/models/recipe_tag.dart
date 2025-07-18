class RecipeTag {
  String? recipeId; // recipe_id (FK to Recipe)
  String? tagId; // tag_id (FK to Tag)

  RecipeTag({
    this.recipeId,
    this.tagId,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipeId,
      'tag_id': tagId,
    };
  }

  factory RecipeTag.fromMap(Map<String, dynamic> map) {
    return RecipeTag(
      recipeId: map['recipe_id'],
      tagId: map['tag_id'],
    );
  }
}