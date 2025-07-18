import 'package:app_goi_y_mon_an/data/sample_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'package:app_goi_y_mon_an/models/user_profile.dart';
import 'package:app_goi_y_mon_an/models/ingredient.dart';
import 'package:app_goi_y_mon_an/models/recipe.dart';
import 'package:app_goi_y_mon_an/models/user_ingredient.dart';
import 'package:app_goi_y_mon_an/models/recipe_ingredient.dart';
import 'package:app_goi_y_mon_an/models/tag.dart';
import 'package:app_goi_y_mon_an/models/recipe_tag.dart';
import 'package:app_goi_y_mon_an/models/user_favorite.dart';
import 'package:app_goi_y_mon_an/models/view_history.dart';
import 'package:app_goi_y_mon_an/models/cooking_history.dart';
import 'package:app_goi_y_mon_an/models/comment.dart';
import 'package:app_goi_y_mon_an/models/collection.dart';
import 'package:app_goi_y_mon_an/models/collection_recipe.dart';
import 'package:app_goi_y_mon_an/models/user_activity.dart';


// Thêm uuid vào pubspec.yaml:
// dependencies:
//   uuid: ^4.3.3


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final Uuid _uuid = const Uuid(); // Để tạo ID duy nhất

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'cookmate_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Thêm onUpgrade để xử lý nâng cấp schema
    );
  }

  // Hàm tạo bảng
  Future _onCreate(Database db, int version) async {
    // profiles (auth.users_id, username, avatar_url, updated_at)
    await db.execute('''
      CREATE TABLE profiles(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        avatar_url TEXT,
        email TEXT, -- Thêm email nếu cần
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // ingredients (id, name, image_url, category, created_at)
    await db.execute('''
      CREATE TABLE ingredients(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        image_url TEXT,
        category TEXT,
        created_at TEXT
      )
    ''');

    // recipes (id, name, description, instructions, image_url, cooking_time_minutes, difficulty, created_at)
    await db.execute('''
      CREATE TABLE recipes(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        instructions TEXT NOT NULL,
        image_url TEXT,
        cooking_time_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // user_ingredients (user_id, ingredient_id, added_at)
    await db.execute('''
      CREATE TABLE user_ingredients(
        user_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        added_at TEXT,
        PRIMARY KEY (user_id, ingredient_id),
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // recipe_ingredients (recipe_id, ingredient_id, quantity)
    await db.execute('''
      CREATE TABLE recipe_ingredients(
        recipe_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        quantity TEXT NOT NULL,
        PRIMARY KEY (recipe_id, ingredient_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // tags (id, name)
    await db.execute('''
      CREATE TABLE tags(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // recipe_tags (recipe_id, tag_id)
    await db.execute('''
      CREATE TABLE recipe_tags(
        recipe_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (recipe_id, tag_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // user_favorites (user_id, recipe_id, created_at)
    await db.execute('''
      CREATE TABLE user_favorites(
        user_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        created_at TEXT,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // view_history (user_id, recipe_id, last_viewed_at)
    await db.execute('''
      CREATE TABLE view_history(
        user_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        last_viewed_at TEXT,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // cooking_history (id, user_id, recipe_id, rating, notes, cooked_at)
    await db.execute('''
      CREATE TABLE cooking_history(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        rating INTEGER,
        notes TEXT,
        cooked_at TEXT,
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // comments (id, user_id, recipe_id, content, created_at)
    await db.execute('''
      CREATE TABLE comments(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // collections (id, user_id, name, description, created_at)
    await db.execute('''
      CREATE TABLE collections(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');

    // collection_recipes (collection_id, recipe_id, added_at)
    await db.execute('''
      CREATE TABLE collection_recipes(
        collection_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        added_at TEXT,
        PRIMARY KEY (collection_id, recipe_id),
        FOREIGN KEY (collection_id) REFERENCES collections (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
    
    // user_activity (id, user_id, activity, created_at)
    await db.execute('''
      CREATE TABLE user_activity(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        activity TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');
  }

  // Hàm nâng cấp database (ví dụ khi bạn thay đổi schema)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ví dụ: Nếu bạn thêm cột mới ở version 2
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE profiles ADD COLUMN new_column TEXT;");
    // }
    // Lưu ý: Các thay đổi phức tạp hơn có thể yêu cầu di chuyển dữ liệu
  }


  // --- Phương thức CRUD cơ bản cho UserProfile ---
  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    profile.id = profile.id ?? _uuid.v4(); // Tạo ID nếu chưa có
    profile.createdAt = profile.createdAt ?? DateTime.now();
    profile.updatedAt = profile.updatedAt ?? DateTime.now();
    return await db.insert('profiles', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserProfile>> getUserProfiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profiles');
    return List.generate(maps.length, (i) {
      return UserProfile.fromMap(maps[i]);
    });
  }

  Future<UserProfile?> getUserProfileById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    profile.updatedAt = DateTime.now();
    return await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteUserProfile(String id) async {
    final db = await database;
    return await db.delete(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Thêm các phương thức CRUD tương tự cho các Models khác ---
  // Ví dụ cho Ingredient:
  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await database;
    ingredient.id = ingredient.id ?? _uuid.v4();
    ingredient.createdAt = ingredient.createdAt ?? DateTime.now();
    return await db.insert('ingredients', ingredient.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ingredient>> getIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');
    return List.generate(maps.length, (i) {
      return Ingredient.fromMap(maps[i]);
    });
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await database;
    return await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<int> deleteIngredient(String id) async {
    final db = await database;
    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ... và cứ tiếp tục với các bảng còn lại (recipes, comments, etc.)
  // Việc triển khai đầy đủ các phương thức CRUD cho tất cả các bảng sẽ rất dài.
  // Bạn có thể tạo các phương thức chung hoặc chỉ thêm khi cần.
  // Ví dụ cho UserFavorite (bảng liên kết):
  Future<int> insertUserFavorite(UserFavorite favorite) async {
    final db = await database;
    favorite.createdAt = favorite.createdAt ?? DateTime.now();
    return await db.insert('user_favorites', favorite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserFavorite>> getUserFavorites(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return UserFavorite.fromMap(maps[i]);
    });
  }

  Future<int> deleteUserFavorite(String userId, String recipeId) async {
    final db = await database;
    return await db.delete(
      'user_favorites',
      where: 'user_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
  }

  Future<void> initializeIngredients() async {
    final db = await database;
    // Kiểm tra xem bảng có rỗng không để tránh thêm trùng lặp
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ingredients'));
    if (count == 0) { // Chỉ thêm nếu bảng rỗng
      for (var ingredient in sampleIngredients) {
        await insertIngredient(ingredient); // Sử dụng phương thức insertIngredient đã tạo
      }
      print('Đã thêm dữ liệu mẫu cho nguyên liệu.');
    } else {
      print('Nguyên liệu đã có dữ liệu, bỏ qua thêm dữ liệu mẫu.');
    }
  }

   Future<int> insertUserIngredient(UserIngredient userIngredient) async {
    final db = await database;
    userIngredient.addedAt = userIngredient.addedAt ?? DateTime.now();
    return await db.insert('user_ingredients', userIngredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Phương thức để lấy danh sách UserIngredient của một người dùng
  Future<List<UserIngredient>> getUserIngredients(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_ingredients',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return UserIngredient.fromMap(maps[i]);
    });
  }

  // PHƯƠNG THỨC BỊ THIẾU HOẶC KHÔNG ĐẦY ĐỦ: deleteUserIngredient
  Future<int> deleteUserIngredient(String userId, String ingredientId) async {
    final db = await database;
    return await db.delete(
      'user_ingredients',
      where: 'user_id = ? AND ingredient_id = ?',
      whereArgs: [userId, ingredientId],
    );
  }

  // Lưu ý về UUID: `id` trong sơ đồ của bạn là UUID (TEXT trong SQLite).
  // Bạn cần thư viện `uuid` để tạo chúng.
  // Thêm `uuid: ^latest_version` vào pubspec.yaml và chạy `flutter pub get`
}