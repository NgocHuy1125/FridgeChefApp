// lib/utils/mock_data.dart

import 'package:app_goi_y_mon_an/models/recipe.dart';
import 'package:app_goi_y_mon_an/models/ingredient.dart';

// (Giữ nguyên phần mockRecipes như cũ nếu bạn muốn)
List<Recipe> mockRecipes = [
  // ... (các công thức đã có)
  Recipe(
    id: 'recipe_1',
    name: 'Phở Bò Truyền Thống',
    description: 'Nước dùng ninh từ xương bò, bánh phở mềm, thịt bò thái mỏng.',
    instructions: 'Chi tiết cách nấu phở bò...',
    imageUrl: 'https://cdn.pixabay.com/photo/2016/12/26/17/28/food-1933501_960_720.jpg',
    cookingTimeMinutes: 120,
    difficulty: 'Trung bình',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    requiredIngredientIds: ['ing_7', 'ing_8', 'ing_1', 'ing_4'],
  ),
  Recipe(
    id: 'recipe_2',
    name: 'Bún Chả Hà Nội',
    description: 'Bún tươi, chả nướng than hoa, nem cua bể giòn tan, nước chấm chua ngọt.',
    instructions: 'Cách ướp thịt và pha nước chấm bún chả...',
    imageUrl: 'https://cdn.pixabay.com/photo/2017/02/05/17/44/bun-cha-2040431_960_720.jpg',
    cookingTimeMinutes: 90,
    difficulty: 'Trung bình',
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
    requiredIngredientIds: ['ing_7', 'ing_4', 'ing_9', 'ing_5'],
  ),
  Recipe(
    id: 'recipe_3',
    name: 'Bánh Mì Kẹp Thịt',
    description: 'Bánh mì giòn rụm với nhân thịt heo quay, pate, dưa chuột và rau mùi.',
    instructions: 'Hướng dẫn làm nhân bánh mì và cách nướng bánh...',
    imageUrl: 'https://cdn.pixabay.com/photo/2017/01/21/08/23/sandwich-1996841_960_720.jpg',
    cookingTimeMinutes: 20,
    difficulty: 'Dễ',
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    requiredIngredientIds: ['ing_7', 'ing_1', 'ing_5'],
  ),
  Recipe(
    id: 'recipe_4',
    name: 'Gỏi Cuốn Tôm Thịt',
    description: 'Món gỏi tươi mát, thanh đạm với tôm, thịt ba chỉ, bún và rau sống.',
    instructions: 'Cách làm nước chấm và cuốn gỏi...',
    imageUrl: 'https://cdn.pixabay.com/photo/2017/08/04/16/23/vietnamese-spring-rolls-2580797_960_720.jpg',
    cookingTimeMinutes: 30,
    difficulty: 'Dễ',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    requiredIngredientIds: ['ing_9', 'ing_7', 'ing_1', 'ing_5'],
  ),
  Recipe(
    id: 'recipe_5',
    name: 'Cơm Tấm Sườn Bì Chả',
    description: 'Đặc sản Sài Gòn với cơm tấm, sườn nướng, bì và chả trứng.',
    instructions: 'Bí quyết ướp sườn và làm chả trứng thơm ngon...',
    imageUrl: 'https://cdn.pixabay.com/photo/2018/06/18/22/58/food-3483918_960_720.jpg',
    cookingTimeMinutes: 60,
    difficulty: 'Trung bình',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    requiredIngredientIds: ['ing_8', 'ing_4'],
  ),
   Recipe(
    id: 'recipe_6',
    name: 'Canh Chua Cá',
    description: 'Món canh chua ngọt miền Nam với cá và rau củ.',
    instructions: 'Sơ chế cá, nấu nước dùng chua với thơm, cà chua, giá, bạc hà.',
    imageUrl: 'https://via.placeholder.com/600x400/98FB98/FFFFFF?text=Canh_Chua_Ca',
    cookingTimeMinutes: 45,
    difficulty: 'Dễ',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    requiredIngredientIds: ['ing_5', 'ing_4', 'ing_10', 'ing_6'],
  ),
  Recipe(
    id: 'recipe_7',
    name: 'Thịt Kho Tàu',
    description: 'Món thịt kho truyền thống Việt Nam với trứng và nước dừa.',
    instructions: 'Kho thịt ba chỉ với nước dừa tươi, trứng luộc, nêm gia vị vừa ăn.',
    imageUrl: 'https://via.placeholder.com/600x400/D2B48C/FFFFFF?text=Thit_Kho_Tau',
    cookingTimeMinutes: 150,
    difficulty: 'Trung bình',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    requiredIngredientIds: ['ing_7', 'ing_4', 'ing_6'],
  ),
];

List<String> mockFavoritedRecipeIds = [
  'recipe_1',
  'recipe_3',
];

// Dữ liệu nguyên liệu giả lập VỚI NHIỀU THỂ LOẠI HƠN
List<Ingredient> sampleIngredients = [
  // --- Rau củ ---
  Ingredient(id: 'ing_1', name: 'Cà rốt', category: 'Rau củ', imageUrl: 'assets/images/ingredients/carrot.png', createdAt: DateTime.now().subtract(const Duration(days: 5))),
  Ingredient(id: 'ing_2', name: 'Khoai tây', category: 'Rau củ', imageUrl: 'assets/images/ingredients/potato.png', createdAt: DateTime.now().subtract(const Duration(days: 4))),
  Ingredient(id: 'ing_3', name: 'Hành tây', category: 'Rau củ', imageUrl: 'assets/images/ingredients/onion.png', createdAt: DateTime.now().subtract(const Duration(days: 3))),
  Ingredient(id: 'ing_4', name: 'Tỏi', category: 'Rau củ', imageUrl: 'assets/images/ingredients/garlic.png', createdAt: DateTime.now().subtract(const Duration(days: 2))),
  Ingredient(id: 'ing_5', name: 'Cà chua', category: 'Rau củ', imageUrl: 'assets/images/ingredients/tomato.png', createdAt: DateTime.now().subtract(const Duration(days: 1))),

  // --- Gia vị cơ bản --- (Danh mục mới)
  Ingredient(id: 'ing_6', name: 'Đường', category: 'Gia vị cơ bản', imageUrl: 'assets/images/ingredients/sugar.png', createdAt: DateTime.now().subtract(const Duration(days: 8))),
  Ingredient(id: 'ing_11', name: 'Muối', category: 'Gia vị cơ bản', imageUrl: 'assets/images/ingredients/salt.png', createdAt: DateTime.now().subtract(const Duration(days: 7))),
  Ingredient(id: 'ing_12', name: 'Hạt nêm', category: 'Gia vị cơ bản', imageUrl: 'assets/images/ingredients/seasoning_powder.png', createdAt: DateTime.now().subtract(const Duration(days: 6))),

  // --- Gia vị khô --- (Danh mục mới)
  Ingredient(id: 'ing_13', name: 'Tiêu', category: 'Gia vị khô', imageUrl: 'assets/images/ingredients/pepper.png', createdAt: DateTime.now().subtract(const Duration(days: 5))),
  Ingredient(id: 'ing_14', name: 'Ớt bột', category: 'Gia vị khô', imageUrl: 'assets/images/ingredients/chili_powder.png', createdAt: DateTime.now().subtract(const Duration(days: 4))),
  Ingredient(id: 'ing_15', name: 'Bột nghệ', category: 'Gia vị khô', imageUrl: 'assets/images/ingredients/turmeric_powder.png', createdAt: DateTime.now().subtract(const Duration(days: 3))),

  // --- Nước chấm/sốt --- (Danh mục mới)
  Ingredient(id: 'ing_16', name: 'Nước mắm', category: 'Nước chấm/sốt', imageUrl: 'assets/images/ingredients/fish_sauce.png', createdAt: DateTime.now().subtract(const Duration(days: 2))),
  Ingredient(id: 'ing_17', name: 'Nước tương', category: 'Nước chấm/sốt', imageUrl: 'assets/images/ingredients/soy_sauce.png', createdAt: DateTime.now().subtract(const Duration(days: 1))),
  Ingredient(id: 'ing_18', name: 'Dầu hào', category: 'Nước chấm/sốt', imageUrl: 'assets/images/ingredients/oyster_sauce.png', createdAt: DateTime.now().subtract(const Duration(days: 0))),

  // --- Thịt & Hải sản ---
  Ingredient(id: 'ing_7', name: 'Thịt gà', category: 'Thịt & Hải sản', imageUrl: 'assets/images/ingredients/chicken.png', createdAt: DateTime.now().subtract(const Duration(days: 5))),
  Ingredient(id: 'ing_8', name: 'Thịt bò', category: 'Thịt & Hải sản', imageUrl: 'assets/images/ingredients/beef.png', createdAt: DateTime.now().subtract(const Duration(days: 4))),
  Ingredient(id: 'ing_9', name: 'Tôm', category: 'Thịt & Hải sản', imageUrl: 'assets/images/ingredients/shrimp.png', createdAt: DateTime.now().subtract(const Duration(days: 3))),
  Ingredient(id: 'ing_10', name: 'Cá hồi', category: 'Thịt & Hải sản', imageUrl: 'assets/images/ingredients/salmon.png', createdAt: DateTime.now().subtract(const Duration(days: 2))),

  // --- Sữa & Sản phẩm từ sữa --- (Danh mục mới)
  Ingredient(id: 'ing_19', name: 'Sữa tươi', category: 'Sữa & Sản phẩm từ sữa', imageUrl: 'assets/images/ingredients/milk.png', createdAt: DateTime.now().subtract(const Duration(days: 10))),
  Ingredient(id: 'ing_20', name: 'Phô mai', category: 'Sữa & Sản phẩm từ sữa', imageUrl: 'assets/images/ingredients/cheese.png', createdAt: DateTime.now().subtract(const Duration(days: 9))),

  // --- Ngũ cốc & Đậu --- (Danh mục mới)
  Ingredient(id: 'ing_21', name: 'Gạo', category: 'Ngũ cốc & Đậu', imageUrl: 'assets/images/ingredients/rice.png', createdAt: DateTime.now().subtract(const Duration(days: 7))),
  Ingredient(id: 'ing_22', name: 'Đậu phụ', category: 'Ngũ cốc & Đậu', imageUrl: 'assets/images/ingredients/tofu.png', createdAt: DateTime.now().subtract(const Duration(days: 6))),
];