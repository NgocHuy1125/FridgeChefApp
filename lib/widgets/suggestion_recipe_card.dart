import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/recipe_model.dart';
import '/providers/my_fridge_provider.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class SuggestionRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const SuggestionRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.watch<UserDataProvider>();
    final isFavorite = userDataProvider.isFavorite(recipe.id);

    final fridgeProvider = context.read<MyFridgeProvider>();
    final myIngredientIds =
        fridgeProvider.myFridgeItems.map((e) => e.ingredientId).toSet();

    final recipeIngredients = recipe.ingredients ?? [];

    final availableIngredients =
        recipeIngredients
            .where((ing) => myIngredientIds.contains(ing.id))
            .toList();
    final totalIngredients = recipeIngredients.length;
    final missingCount = totalIngredients - availableIngredients.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => RecipeDetailScreenWrapper(recipeId: recipe.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          children: [
            _buildImageHeader(context, isFavorite, userDataProvider),
            _buildInfoBody(
              availableIngredients,
              missingCount,
              totalIngredients,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(
    BuildContext context,
    bool isFavorite,
    UserDataProvider userDataProvider,
  ) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền món ăn
          CachedNetworkImage(
            imageUrl: recipe.imageUrl ?? '',
            fit: BoxFit.cover,
            errorWidget: (c, u, e) => Container(color: Colors.grey[200]),
          ),
          // Lớp phủ mờ để làm nổi bật chữ
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _buildActionButton(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  () => userDataProvider.toggleFavorite(recipe),
                  isFavorite ? Colors.red : Colors.white,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.bookmark_add_outlined,
                  () => userDataProvider.addToCollection(recipe.id),
                  Colors.white,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.star, '4.5', Colors.yellow.shade700),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      Icons.timer_outlined,
                      '${recipe.cookingTimeMinutes ?? '?'} phút',
                      Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      Icons.people_outline,
                      '2 người',
                      Colors.white,
                    ), // Dữ liệu giả
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBody(
    List<dynamic> availableIngredients,
    int missingCount,
    int totalIngredients,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  recipe.difficulty ?? 'Dễ',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green.shade100,
                side: BorderSide.none,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('$totalIngredients nguyên liệu'),
                backgroundColor: Colors.grey.shade200,
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Nguyên liệu có sẵn:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (availableIngredients.isEmpty && missingCount == 0)
            const Text(
              'Không có thông tin nguyên liệu.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ...availableIngredients
                    .take(3)
                    .map(
                      (ing) => Chip(
                        avatar: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                        label: Text(ing.name),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    ),
                // Hiển thị số lượng còn thiếu
                if (missingCount > 0)
                  Chip(
                    label: Text('+${missingCount} khác'),
                    backgroundColor: Colors.grey.shade200,
                    side: BorderSide.none,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color iconColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed,
    Color iconColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
