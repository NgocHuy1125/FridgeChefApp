import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/recipe_model.dart';
import '/providers/recipe_detail_provider.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreenWrapper extends StatelessWidget {
  final int recipeId;
  const RecipeDetailScreenWrapper({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.read<UserDataProvider>();

    return ChangeNotifierProvider(
      create:
          (_) =>
              RecipeDetailProvider()
                ..fetchRecipeDetails(recipeId, userDataProvider),
      child: const RecipeDetailScreen(),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeDetailProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, RecipeDetailProvider provider) {
    switch (provider.status) {
      case DetailStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case DetailStatus.error:
        return Center(child: Text(provider.errorMessage));
      case DetailStatus.success:
        if (provider.recipe == null) {
          return const Center(child: Text("Không thể tải thông tin món ăn."));
        }
        final recipe = provider.recipe!;
        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, recipe),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIngredientsSection(recipe),
                    const SizedBox(height: 24),
                    _buildProgressSection(context, provider),
                    const SizedBox(height: 24),
                    _buildInstructionsSection(context, provider),
                    const SizedBox(height: 24),
                    _buildCompleteButton(context, recipe),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildSliverAppBar(BuildContext context, Recipe recipe) {
    final userDataProvider = context.watch<UserDataProvider>();
    final isFavorite = userDataProvider.isFavorite(recipe.id);

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        title: Text(
          recipe.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black54,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: recipe.imageUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (c, u, e) => Container(color: Colors.grey),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed:
              () => context.read<UserDataProvider>().toggleFavorite(recipe),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(Recipe recipe) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.kitchen, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Nguyên liệu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recipe.ingredients.isEmpty)
              const Text(
                'Không có thông tin nguyên liệu chi tiết.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...recipe.ingredients.map(
                (ingredient) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.green,
                  ),
                  title: Text(ingredient.name),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    RecipeDetailProvider provider,
  ) {
    final progress =
        provider.totalSteps == 0
            ? 0.0
            : provider.completedSteps.length / provider.totalSteps;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Tiến độ: ${provider.completedSteps.length}/${provider.totalSteps}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.orange[100],
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn để đánh dấu hoàn thành',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(
    BuildContext context,
    RecipeDetailProvider provider,
  ) {
    final steps = provider.steps;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.format_list_numbered, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Hướng dẫn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (steps.isEmpty)
              const Text(
                'Không có hướng dẫn chi tiết.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...List.generate(steps.length, (index) {
                final isCompleted = provider.completedSteps.contains(index);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: isCompleted ? Colors.green : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    steps[index].trim(),
                    style: TextStyle(
                      decoration:
                          isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      color: isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  onTap: () => provider.toggleStep(index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context, Recipe recipe) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Hoàn thành món ăn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // *** SỬA LỖI DUY NHẤT Ở ĐÂY ***
            // Truyền vào cả đối tượng `recipe` thay vì chỉ `recipe.id`
            context.read<UserDataProvider>().addCookingToHistory(recipe);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã lưu vào lịch sử nấu ăn!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Iconsax.play),
            label: const Text('Xem video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final url = Uri.parse(recipe.youtubeUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Không thể mở link: ${recipe.youtubeUrl}'),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
