import 'package:flutter/material.dart';
import '/models/ingredient_model.dart';
import '/providers/my_fridge_provider.dart';
import '/widgets/suggestion_recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class MyFridgeScreenWrapper extends StatelessWidget {
  const MyFridgeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyFridgeProvider()..initialize(),
      child: const MyFridgeScreen(),
    );
  }
}

class MyFridgeScreen extends StatelessWidget {
  const MyFridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child:
                  provider.isScreenLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            provider.currentView == FridgeView.fridge
                                ? _buildFridgeContent(context)
                                : _buildSuggestionContent(context),
                      ),
            ),
          ],
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

  Widget _buildFridgeContent(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();
    return RefreshIndicator(
      onRefresh: () => provider.fetchMyFridgeItems(),
      child: CustomScrollView(
        key: const PageStorageKey('fridgeList'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildAddIngredientSection(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPopularIngredientsSection(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildSuggestionContent(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();

    // Nếu đang tải, hiển thị vòng xoay
    if (provider.isSuggesting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nếu không có kết quả, hiển thị thông báo
    if (provider.suggestedRecipes.isEmpty) {
      return const Center(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gợi ý món ăn',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Từ ${provider.myFridgeItems.length} nguyên liệu trong tủ lạnh',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('suggestionList'),
            padding: const EdgeInsets.all(16),
            itemCount: provider.suggestedRecipes.length,
            itemBuilder: (context, index) {
              return SuggestionRecipeCard(
                recipe: provider.suggestedRecipes[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddIngredientSection(BuildContext context) {
    final provider = context.read<MyFridgeProvider>();
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
            Autocomplete<Ingredient>(
              displayStringForOption: (Ingredient option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                return provider.getFilteredSuggestions(textEditingValue.text);
              },
              onSelected: (Ingredient selection) {
                provider.toggleIngredientInFridge(selection.name);
              },
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onFieldSubmitted,
              ) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên hoặc tìm kiếm...',
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
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            provider.toggleIngredientInFridge(value);
                            controller.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            provider.isProcessing(controller.text)
                                ? null
                                : () {
                                  if (controller.text.isNotEmpty) {
                                    provider.toggleIngredientInFridge(
                                      controller.text,
                                    );
                                    controller.clear();
                                    focusNode.unfocus();
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          disabledBackgroundColor: Colors.orange.shade200,
                        ),
                        child:
                            provider.isProcessing(controller.text)
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 68,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final Ingredient option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularIngredientsSection(BuildContext context) {
    final provider = context.watch<MyFridgeProvider>();
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
                  onSelected:
                      isProcessing
                          ? null
                          : (bool selected) {
                            context
                                .read<MyFridgeProvider>()
                                .toggleIngredientInFridge(ingredient.name);
                          },
                  avatar: Icon(
                    isInFridge ? Icons.check_circle : Icons.add,
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

  Widget _buildIngredientList(
    BuildContext context,
    List<UserIngredient> ingredients,
  ) {
    return Column(
      children:
          ingredients
              .map((item) => _buildIngredientTile(context, item))
              .toList(),
    );
  }

  Widget _buildIngredientTile(BuildContext context, UserIngredient ingredient) {
    final categoryColor =
        (ingredient.category ?? '').toLowerCase().contains('thịt')
            ? Colors.red.shade100
            : Colors.green.shade100;
    final categoryTextColor =
        (ingredient.category ?? '').toLowerCase().contains('thịt')
            ? Colors.red.shade800
            : Colors.green.shade800;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              if (ingredient.category != null &&
                  ingredient.category!.isNotEmpty)
                Chip(
                  label: Text(
                    ingredient.category!,
                    style: TextStyle(
                      color: categoryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: categoryColor,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              const Text(
                '3 ngày nữa hết hạn',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
          onPressed:
              () => context.read<MyFridgeProvider>().removeIngredientFromFridge(
                ingredient.ingredientId,
              ),
        ),
      ),
    );
  }
}
