import 'package:flutter/material.dart';
import '/models/recipe_model.dart';
import '/screens/recipe_detail_screen.dart';
import '/providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();
    context.read<SearchProvider>().searchAllSources(_searchController.text);
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
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nhập tên món ăn (vd: chicken, beef)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RecipeDetailScreenWrapper(
                                      recipeId: int.tryParse(recipe.id) ?? 0,
                                    ),
                              ),
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
