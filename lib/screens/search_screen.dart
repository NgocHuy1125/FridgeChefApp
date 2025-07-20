import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Wrapper không thay đổi
class SearchScreenWrapper extends StatelessWidget {
  const SearchScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: const SearchScreen(),
    );
  }
}

// Chuyển thành StatefulWidget
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 1. Tạo một TextEditingController
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm để gọi tìm kiếm, tránh lặp code
  void _performSearch() {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();
    // Gọi hàm search từ provider với giá trị hiện tại của controller
    context.read<SearchProvider>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm Công thức')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              // 2. Gán controller cho TextField
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nhập tên món ăn (vd: chicken, beef)',
                // 3. Sửa lại suffixIcon để nó là một IconButton
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  // 4. Khi nhấn vào icon, gọi hàm _performSearch
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // 5. Khi nhấn Enter trên bàn phím, cũng gọi hàm _performSearch
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                // ... (phần builder này giữ nguyên không thay đổi)
                switch (provider.status) {
                  case SearchStatus.initial:
                    return const Center(
                      child: Text('Bắt đầu tìm kiếm món ăn.'),
                    );
                  case SearchStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case SearchStatus.success:
                    if (provider.searchResults.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy kết quả nào.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final recipe = provider.searchResults[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: recipe.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => const Icon(Icons.image),
                          ),
                          title: Text(recipe.name),
                          onTap: () {
                            // TODO: Logic điều hướng
                            print(
                              'Tapped on API recipe: ${recipe.name} (ID: ${recipe.id})',
                            );
                          },
                        );
                      },
                    );
                  case SearchStatus.error:
                    return Center(child: Text('Lỗi: ${provider.errorMessage}'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
