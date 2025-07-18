import 'package:flutter/material.dart';
import 'package:fridge_chef_app/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> categories = [];
  String selectedCategory = '';
  List<Map<String, dynamic>> meals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final fetchedCategories = await MealDBApi.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        selectedCategory = fetchedCategories.first;
      });
      await loadMealsByCategory(selectedCategory);
    } catch (e) {
      print('Lỗi loadCategories: $e');
    }
  }

  Future<void> loadMealsByCategory(String category) async {
    setState(() => isLoading = true);
    try {
      final fetchedMeals = await MealDBApi.fetchMealsByCategory(category);
      setState(() {
        meals = fetchedMeals;
        selectedCategory = category;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi loadMealsByCategory: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ - TheMealDB")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh sách danh mục
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () => loadMealsByCategory(category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Danh sách món ăn
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Image.network(
                              meal['strMealThumb'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(meal['strMeal']),
                            onTap: () {
                              // TODO: Điều hướng sang trang chi tiết món ăn
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: meal['idMeal'],
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
