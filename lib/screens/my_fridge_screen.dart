import 'package:flutter/material.dart';
import '../models/ingredient_model.dart';
import '../providers/my_fridge_provider.dart';
import '../widgets/suggestion_recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class MyFridgeScreenWrapper extends StatelessWidget {
  const MyFridgeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ cần MyFridgeProvider là đủ ở đây
    return ChangeNotifierProvider(
      create: (_) => MyFridgeProvider()..initialize(),
      child: const MyFridgeScreen(),
    );
  }
}

class MyFridgeScreen extends StatefulWidget {
  const MyFridgeScreen({super.key});

  @override
  State<MyFridgeScreen> createState() => _MyFridgeScreenState();
}

class _MyFridgeScreenState extends State<MyFridgeScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredientToFridge() {
    final provider = context.read<MyFridgeProvider>();
    final ingredientName = _ingredientController.text.trim();
    if (ingredientName.isNotEmpty) {
      provider.toggleIngredientInFridge(ingredientName);
      _ingredientController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child:
                    provider.isScreenLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              provider.currentView == FridgeView.fridge
                                  ? _buildFridgeContent(context, provider)
                                  : _buildSuggestionContent(context, provider),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tủ Lạnh Thông Minh',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gợi ý món ăn từ nguyên liệu có sẵn',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<FridgeView>(
              backgroundColor: Colors.grey.shade200,
              thumbColor: const Color(0xFF5CB85C),
              groupValue: provider.currentView,
              children: {
                FridgeView.fridge: _buildSegment(
                  'Tủ lạnh',
                  provider.currentView == FridgeView.fridge,
                ),
                FridgeView.suggestions: _buildSegment(
                  'Gợi ý món',
                  provider.currentView == FridgeView.suggestions,
                ),
              },
              onValueChanged: (value) {
                if (value == FridgeView.fridge) {
                  context.read<MyFridgeProvider>().showFridgeView();
                } else if (value == FridgeView.suggestions) {
                  if (context.read<MyFridgeProvider>().myFridgeItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng thêm ít nhất một nguyên liệu!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    context.read<MyFridgeProvider>().showSuggestionsView();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildFridgeContent(BuildContext context, MyFridgeProvider provider) {
    return RefreshIndicator(
      key: const PageStorageKey('fridge_content'),
      onRefresh: () => provider.fetchMyFridgeItems(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildAddIngredientSection(context, provider),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPopularIngredientsSection(context, provider),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildIngredientListHeader(provider.myFridgeItems.length),
            ),
          ),
          if (provider.myFridgeItems.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildIngredientTile(
                    context,
                    provider.myFridgeItems[index],
                  ),
                  childCount: provider.myFridgeItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // NỘI DUNG VIEW GỢI Ý
  Widget _buildSuggestionContent(
    BuildContext context,
    MyFridgeProvider provider,
  ) {
    if (provider.isSuggesting) {
      return const Center(
        key: ValueKey('suggest_loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.suggestedRecipes.isEmpty) {
      return const Center(
        key: ValueKey('suggest_empty'),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Không tìm thấy món ăn phù hợp với nguyên liệu của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('suggestionList'),
      padding: const EdgeInsets.all(16),
      itemCount: provider.suggestedRecipes.length,
      itemBuilder: (context, index) {
        return SuggestionRecipeCard(recipe: provider.suggestedRecipes[index]);
      },
    );
  }

  Widget _buildAddIngredientSection(
    BuildContext context,
    MyFridgeProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '+',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Thêm thực phẩm mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hoặc chọn ở dưới...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _addIngredientToFridge(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _addIngredientToFridge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularIngredientsSection(
    BuildContext context,
    MyFridgeProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gợi ý nhanh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children:
              provider.popularDbIngredients.map((ingredient) {
                final isInFridge = provider.myFridgeItems.any(
                  (item) => item.ingredientId == ingredient.id,
                );
                final isProcessing = provider.isProcessing(ingredient.name);
                return FilterChip(
                  label:
                      isProcessing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(ingredient.name),
                  selected: isInFridge,
                  onSelected: (bool selected) {
                    if (isProcessing) return;
                    _ingredientController.text = ingredient.name;
                    _ingredientController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: _ingredientController.text.length),
                    );
                    _focusNode.requestFocus();
                  },
                  avatar: Icon(
                    isInFridge ? Icons.check_circle : Icons.add_circle_outline,
                    color: isInFridge ? Colors.white : Colors.grey.shade600,
                    size: 18,
                  ),
                  labelStyle: TextStyle(
                    color: isInFridge ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.green,
                  checkmarkColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isInFridge ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildIngredientListHeader(int count) {
    return Row(
      children: [
        Icon(Icons.kitchen_outlined, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Text(
          'Thực phẩm trong tủ lạnh ($count)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Text(
          'Tủ lạnh của bạn đang trống!',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildIngredientTile(BuildContext context, UserIngredient ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
          onPressed:
              () => context.read<MyFridgeProvider>().toggleIngredientInFridge(
                ingredient.name,
              ),
        ),
      ),
    );
  }
}
