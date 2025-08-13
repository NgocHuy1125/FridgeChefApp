import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      appBar: AppBar(
        title: const Text(
          'Hồ sơ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
=======
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
                      child: provider.cookedHistory.isEmpty
                          ? _buildEmptyState(
                              'Bạn chưa nấu món nào',
                              Icons.menu_book,
                            )
                          : _buildRecipeHorizontalList(provider.cookedHistory),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ProfileProvider provider) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.purple.shade100,
          child:
              provider.userProfile?.avatarUrl != null
                  ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: provider.userProfile!.avatarUrl!,
                    ),
                  )
                  : Icon(Icons.person, size: 50, color: Colors.purple.shade300),
>>>>>>> Stashed changes
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Nội dung màn hình Hồ sơ'),
      ),
    );
  }
}