import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/recipe_model.dart';
import '/providers/recipe_detail_provider.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class RecipeDetailScreenWrapper extends StatelessWidget {
  final int recipeId;
  const RecipeDetailScreenWrapper({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipeDetailProvider()..fetchRecipeDetails(recipeId),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDataProvider()..fetchInitialUserData(),
        ),
      ],
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
            color: Colors.white, // 🌟 Màu trắng nổi bật
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black54,
                offset: Offset(2, 2), // đổ bóng giúp chữ nổi hơn
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
            // Lớp gradient để ảnh phía trên tối hơn -> chữ dễ đọc
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
          onPressed: () => userDataProvider.toggleFavorite(recipe),
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
            Row(
              children: [
                const Icon(Icons.kitchen, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
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
            ...recipe.ingredients.map(
              (ingredient) => ListTile(
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
            Row(
              children: [
                const Icon(Icons.format_list_numbered, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
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
            ...List.generate(steps.length, (index) {
              final isCompleted = provider.completedSteps.contains(index);
              return ListTile(
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã lưu vào lịch sử!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        const SizedBox(height: 16), // Khoảng cách giữa các nút
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
            onPressed: () {
              final url = recipe.youtubeUrl ?? '';
              launchUrl(Uri.parse(url)).then((value) {}).catchError((e) {});
            },
          ),
      ],
    );
  }
}
