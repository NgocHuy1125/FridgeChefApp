class RecipeIngredient {
  String? recipeId; // recipe_id (FK to Recipe)
  String? ingredientId; // ingredient_id (FK to Ingredient)
  String quantity; // quantity

  RecipeIngredient({
    this.recipeId,
    this.ingredientId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      recipeId: map['recipe_id'],
      ingredientId: map['ingredient_id'],
      quantity: map['quantity'],
    );
  }
}