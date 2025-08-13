// Để tạo ID duy nhất cho mỗi nguyên liệu
import 'package:app_goi_y_mon_an/utils/helpers.dart'; // <-- Cập nhật đường dẫn

// Import model Ingredient
import 'package:app_goi_y_mon_an/models/ingredient.dart'; // <-- Cập nhật đường dẫn

// Danh sách các nguyên liệu mẫu và nhóm của chúng
List<Ingredient> sampleIngredients = [
  // --- Rau củ ---
  Ingredient(
    id: uuid.v4(), // Sử dụng uuid từ file helpers
    name: 'Cà rốt',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/carrot.png',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Khoai tây',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/potato.png',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Hành tây',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/onion.png',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Tỏi',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/garlic.png',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Cà chua',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/tomato.png',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Bông cải xanh',
    category: 'Rau củ',
    imageUrl: 'assets/images/ingredients/broccoli.png',
    createdAt: DateTime.now(),
  ),

  // --- Gia vị ---
  Ingredient(
    id: uuid.v4(),
    name: 'Muối',
    category: 'Gia vị',
    imageUrl: 'assets/images/ingredients/salt.png',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Tiêu',
    category: 'Gia vị',
    imageUrl: 'assets/images/ingredients/pepper.png',
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Đường',
    category: 'Gia vị',
    imageUrl: 'assets/images/ingredients/sugar.png',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Dầu ăn',
    category: 'Gia vị',
    imageUrl: 'assets/images/ingredients/cooking_oil.png',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Nước mắm',
    category: 'Gia vị',
    imageUrl: 'assets/images/ingredients/fish_sauce.png',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),

  // --- Thịt & Hải sản ---
  Ingredient(
    id: uuid.v4(),
    name: 'Thịt gà',
    category: 'Thịt & Hải sản',
    imageUrl: 'assets/images/ingredients/chicken.png',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Thịt bò',
    category: 'Thịt & Hải sản',
    imageUrl: 'assets/images/ingredients/beef.png',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Tôm',
    category: 'Thịt & Hải sản',
    imageUrl: 'assets/images/ingredients/shrimp.png',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Cá hồi',
    category: 'Thịt & Hải sản',
    imageUrl: 'assets/images/ingredients/salmon.png',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),

  // --- Sữa & Sản phẩm từ sữa ---
  Ingredient(
    id: uuid.v4(),
    name: 'Sữa tươi',
    category: 'Sữa & Sản phẩm từ sữa',
    imageUrl: 'assets/images/ingredients/milk.png',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Bơ',
    category: 'Sữa & Sản phẩm từ sữa',
    imageUrl: 'assets/images/ingredients/butter.png',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Phô mai',
    category: 'Sữa & Sản phẩm từ sữa',
    imageUrl: 'assets/images/ingredients/cheese.png',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),

  // --- Ngũ cốc & Sản phẩm từ bột ---
  Ingredient(
    id: uuid.v4(),
    name: 'Gạo',
    category: 'Ngũ cốc & Sản phẩm từ bột',
    imageUrl: 'assets/images/ingredients/rice.png',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Bột mì',
    category: 'Ngũ cốc & Sản phẩm từ bột',
    imageUrl: 'assets/images/ingredients/flour.png',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Mì spaghetti',
    category: 'Ngũ cốc & Sản phẩm từ bột',
    imageUrl: 'assets/images/ingredients/spaghetti.png',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),

  // --- Trái cây ---
  Ingredient(
    id: uuid.v4(),
    name: 'Táo',
    category: 'Trái cây',
    imageUrl: 'assets/images/ingredients/apple.png',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Ingredient(
    id: uuid.v4(),
    name: 'Chuối',
    category: 'Trái cây',
    imageUrl: 'assets/images/ingredients/banana.png',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];