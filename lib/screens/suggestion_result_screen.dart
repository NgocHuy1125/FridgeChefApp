import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../widgets/suggestion_recipe_card.dart';

class SuggestionResultScreen extends StatelessWidget {
  final List<Recipe> suggestedRecipes;
  final int totalIngredientsInFridge;

  const SuggestionResultScreen({
    super.key,
    required this.suggestedRecipes,
    required this.totalIngredientsInFridge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.grey[100],
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Gợi ý món ăn',
              style: TextStyle(
                color: Color(0xFF00BFA6),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                'Từ $totalIngredientsInFridge nguyên liệu trong tủ lạnh',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

          suggestedRecipes.isEmpty
              ? SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy món ăn phù hợp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return SuggestionRecipeCard(
                      recipe: suggestedRecipes[index],
                    );
                  }, childCount: suggestedRecipes.length),
                ),
              ),
        ],
      ),
    );
  }
}
