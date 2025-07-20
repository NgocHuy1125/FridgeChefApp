import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import '/providers/favorites_provider.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Wrapper để cung cấp FavoritesProvider
class FavoritesScreenWrapper extends StatelessWidget {
  const FavoritesScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const FavoritesScreen(),
    );
  }
}

// UI
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm fetch khi màn hình được tạo
    // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetchFavoriteRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe cả hai provider
    final favProvider = context.watch<FavoritesProvider>();
    // Dùng watch UserDataProvider để UI tự cập nhật khi một món bị bỏ thích
    final userDataProvider = context.watch<UserDataProvider>();

    // Mỗi khi danh sách ID thay đổi, tải lại danh sách chi tiết
    // (Đây là một cách đơn giản, có thể tối ưu hơn với Stream)
    if (userDataProvider.favoriteRecipeIds.length !=
            favProvider.favoriteRecipes.length &&
        !favProvider.isLoading) {
      favProvider.fetchFavoriteRecipes();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Món ăn yêu thích')),
      body: _buildBody(favProvider, userDataProvider),
    );
  }

  Widget _buildBody(
    FavoritesProvider favProvider,
    UserDataProvider userDataProvider,
  ) {
    if (favProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favProvider.favoriteRecipes.isEmpty) {
      return const Center(child: Text('Bạn chưa có món ăn yêu thích nào.'));
    }

    return RefreshIndicator(
      onRefresh: () => favProvider.fetchFavoriteRecipes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: favProvider.favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favProvider.favoriteRecipes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: recipe.imageUrl ?? '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => const Icon(Icons.image),
              ),
              title: Text(
                recipe.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // Gọi hàm toggle từ UserDataProvider
                  userDataProvider.toggleFavorite(recipe);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => RecipeDetailScreenWrapper(recipeId: recipe.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
