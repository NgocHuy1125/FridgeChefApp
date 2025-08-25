import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ingredient_model.dart';
import '../providers/my_fridge_provider.dart';
import '../widgets/suggestion_recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class MyFridgeScreenWrapper extends StatelessWidget {
  const MyFridgeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyFridgeProvider(),
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
  final ScrollController _quickSuggestScrollController = ScrollController();

  Ingredient? _selectedIngredient;

  @override
  void initState() {
    super.initState();
    _ingredientController.addListener(_onTextChanged);
    _quickSuggestScrollController.addListener(_onQuickSuggestScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MyFridgeProvider>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _ingredientController.removeListener(_onTextChanged);
    _quickSuggestScrollController.removeListener(_onQuickSuggestScroll);
    _ingredientController.dispose();
    _focusNode.dispose();
    _quickSuggestScrollController.dispose();
    super.dispose();
  }

  void _onQuickSuggestScroll() {
    final provider = context.read<MyFridgeProvider>();
    if (_quickSuggestScrollController.position.pixels >=
            _quickSuggestScrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore &&
        provider.hasMoreIngredients) {
      provider.fetchMoreIngredients();
    }
  }

  void _onTextChanged() {
    if (_selectedIngredient != null &&
        _ingredientController.text != _selectedIngredient!.name) {
      setState(() {
        _selectedIngredient = null;
      });
    }
  }

  void _addIngredientToFridge() {
    final provider = context.read<MyFridgeProvider>();
    final ingredientToAdd = _selectedIngredient;

    if (ingredientToAdd != null) {
      provider.toggleIngredientInFridge(ingredientToAdd.name);

      _ingredientController.clear();
      setState(() {
        _selectedIngredient = null;
      });
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
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
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
      key: const ValueKey('header'),
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
                if (value == null) return;
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
      key: const ValueKey('fridge_content'),
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
            Autocomplete<Ingredient>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return provider.getFilteredSuggestions(textEditingValue.text);
              },
              displayStringForOption: (Ingredient option) => option.name,
              onSelected: (Ingredient selection) {
                setState(() {
                  _selectedIngredient = selection;
                });
                _ingredientController.text = selection.name;
                _focusNode.unfocus();
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                Future.microtask(() {
                  if (_ingredientController.text !=
                      textEditingController.text) {
                    textEditingController.text = _ingredientController.text;
                  }
                });

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên nguyên liệu...',
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            _selectedIngredient != null
                                ? _addIngredientToFridge
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          disabledBackgroundColor: Colors.orange.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 250,
                        maxWidth: MediaQuery.of(context).size.width - 32 - 16,
                      ),
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
        SizedBox(
          height: 300,
          child: GridView.builder(
            controller: _quickSuggestScrollController,
            padding: const EdgeInsets.symmetric(vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 2.5,
            ),
            itemCount:
                provider.quickSuggestIngredients.length +
                (provider.hasMoreIngredients ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.quickSuggestIngredients.length) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final ingredient = provider.quickSuggestIngredients[index];
              final isInFridge = provider.myFridgeItems.any(
                (item) =>
                    item.name.toLowerCase() == ingredient.name.toLowerCase(),
              );
              final isProcessing = provider.isProcessing(ingredient.name);

              return FilterChip(
                label:
                    isProcessing
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                isInFridge
                                    ? Colors.white
                                    : Colors.grey.shade600,
                          ),
                        )
                        : Text(
                          ingredient.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                selected: isInFridge,
                onSelected: (bool selected) {
                  if (isProcessing) return;
                  context.read<MyFridgeProvider>().toggleIngredientInFridge(
                    ingredient.name,
                  );
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
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isInFridge ? Colors.green : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
            'Không tìm thấy món ăn phù hợp.',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: ingredient.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(color: Colors.grey.shade200),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Icons.kitchen_outlined,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
