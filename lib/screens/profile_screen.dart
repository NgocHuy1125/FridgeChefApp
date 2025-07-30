import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import '/providers/profile_provider.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..fetchProfileData(),
      child: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    context.watch<UserDataProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          provider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : RefreshIndicator(
                onRefresh:
                    () => context.read<ProfileProvider>().fetchProfileData(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  children: [
                    _buildUserInfo(context, provider),
                    const SizedBox(height: 24),
                    _buildStatsSection(provider),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Món ăn đã xem gần đây',
                      icon: Icons.history,
                      iconColor: Colors.orange,
                      child: _buildRecipeHorizontalList(provider.viewedHistory),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Món ăn yêu thích',
                      icon: Icons.favorite,
                      iconColor: Colors.pink,
                      child: _buildRecipeHorizontalList(
                        provider.favoriteRecipes,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Lịch sử nấu ăn',
                      icon: Icons.soup_kitchen_outlined,
                      iconColor: Colors.green,
                      child: _buildEmptyState(
                        'Bạn chưa nấu món nào',
                        Icons.menu_book,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ProfileProvider provider) {
    return Row(
      children: [
        const Icon(Icons.person, size: 50, color: Colors.purple),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.userProfile?.username ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Thành viên mới',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.grey),
          tooltip: 'Đăng xuất',
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Xác nhận Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    TextButton(
                      child: const Text('Đăng xuất'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<ProfileProvider>().signOut();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection(ProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(provider.cookedCount.toString(), 'Món đã nấu'),
            _buildStatItem(provider.collectionCount.toString(), 'Bộ sưu tập'),
            _buildStatItem(provider.favoriteCount.toString(), 'Yêu thích'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: iconColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeHorizontalList(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return _buildEmptyState('Chưa có món ăn nào', Icons.no_food);
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: recipe.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget:
                          (c, u, e) => Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
