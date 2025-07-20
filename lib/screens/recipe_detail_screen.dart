import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return ChangeNotifierProvider(
      create: (_) => RecipeDetailProvider()..fetchRecipeDetails(recipeId),
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
                    _buildInfoSection(recipe),
                    const SizedBox(height: 24),
                    _buildIngredientsSection(recipe),
                    const SizedBox(height: 24),
                    _buildProgressSection(context),
                    const SizedBox(height: 24),
                    _buildInstructionsSection(context, recipe),
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
    // Dùng watch ở đây để nút trái tim cập nhật ngay lập tức
    final userDataProvider = context.watch<UserDataProvider>();
    final isFavorite = userDataProvider.isFavorite(recipe.id);

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 2,
      foregroundColor: Colors.white, // Màu cho nút back và các icon
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        title: Text(
          recipe.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Dùng read ở đây vì chỉ gọi hành động, không cần build lại appbar
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed:
              () => context.read<UserDataProvider>().toggleFavorite(recipe),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white),
          onPressed:
              () => context.read<UserDataProvider>().addToCollection(recipe.id),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Recipe recipe) {
    return _buildSectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Thông tin món ăn',
      titleColor: Colors.blue.shade400,
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          if (recipe.difficulty != null)
            _buildInfoDetailChip('Độ khó: ${recipe.difficulty}'),
          if (recipe.cookingTimeMinutes != null)
            _buildInfoDetailChip(
              'Thời gian: ${recipe.cookingTimeMinutes} phút',
            ),
          _buildInfoDetailChip('Khẩu phần: 2 người'), // Dữ liệu giả
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(Recipe recipe) {
    final ingredients = recipe.ingredients ?? [];
    return _buildSectionCard(
      icon: Icons.kitchen_outlined,
      title: 'Nguyên liệu cần thiết',
      titleColor: Colors.green.shade600,
      child:
          ingredients.isEmpty
              ? const Text('Không có thông tin nguyên liệu.')
              : Column(
                children:
                    ingredients
                        .map(
                          (item) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green.shade300,
                                  size: 12,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                // TODO: Hiển thị `quantity`
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final provider = context.watch<RecipeDetailProvider>();
    final progress =
        provider.totalSteps == 0
            ? 0.0
            : provider.completedSteps.length / provider.totalSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          Text(
            'Tiến độ nấu ăn: ${provider.completedSteps.length}/${provider.totalSteps}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.orange.shade100,
            color: Colors.orange,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn vào từng bước để đánh dấu hoàn thành',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context, Recipe recipe) {
    final provider = context.read<RecipeDetailProvider>();
    final completedSteps = context.watch<RecipeDetailProvider>().completedSteps;
    final steps =
        recipe.instructions
            ?.split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        [];

    return _buildSectionCard(
      icon: Icons.format_list_numbered_rounded,
      title: 'Cách thực hiện',
      titleColor: Colors.purple.shade400,
      child:
          steps.isEmpty
              ? const Text('Không có hướng dẫn chi tiết.')
              : Column(
                children: List.generate(steps.length, (index) {
                  final isCompleted = completedSteps.contains(index);
                  return GestureDetector(
                    onTap: () => provider.toggleStep(index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: isCompleted ? 0 : 2,
                      color: isCompleted ? Colors.grey.shade200 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    isCompleted
                                        ? Colors.grey
                                        : Colors.purple.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child:
                                    isCompleted
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                        : Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                steps[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  decoration:
                                      isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                  color:
                                      isCompleted
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
    );
  }

  Widget _buildCompleteButton(BuildContext context, Recipe recipe) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('Hoàn thành món ăn'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        // TODO: Gọi hàm lưu vào cooking_history từ một provider
        print('Completed recipe: ${recipe.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào lịch sử nấu ăn!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color titleColor,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: titleColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 0.5),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDetailChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(
        color: Colors.blue.shade800,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
