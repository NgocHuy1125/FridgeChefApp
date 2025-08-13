class CollectionRecipe {
  String? collectionId; // collection_id (FK to Collection)
  String? recipeId; // recipe_id (FK to Recipe)
  DateTime? addedAt; // added_at

  CollectionRecipe({
    this.collectionId,
    this.recipeId,
    this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'collection_id': collectionId,
      'recipe_id': recipeId,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  factory CollectionRecipe.fromMap(Map<String, dynamic> map) {
    return CollectionRecipe(
      collectionId: map['collection_id'],
      recipeId: map['recipe_id'],
      addedAt: map['added_at'] != null ? DateTime.parse(map['added_at']) : null,
    );
  }
}