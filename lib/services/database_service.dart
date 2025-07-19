
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_goi_y_mon_an/models/collection.dart';
import 'package:app_goi_y_mon_an/models/collection_recipe.dart';
import 'package:app_goi_y_mon_an/models/comment.dart';
import 'package:app_goi_y_mon_an/models/cooking_history.dart';
import 'package:app_goi_y_mon_an/models/ingredient.dart';
import 'package:app_goi_y_mon_an/models/recipe.dart';
import 'package:app_goi_y_mon_an/models/recipe_ingredient.dart';
import 'package:app_goi_y_mon_an/models/recipe_tag.dart';
import 'package:app_goi_y_mon_an/models/user_activity.dart';
import 'package:app_goi_y_mon_an/models/user_favorite.dart';
import 'package:app_goi_y_mon_an/models/user_ingredient.dart';
import 'package:app_goi_y_mon_an/models/user_profile.dart';
import 'package:app_goi_y_mon_an/models/view_history.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recipe_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // UserProfile Table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT,
        avatar_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Recipe Table
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        instructions TEXT NOT NULL,
        image_url TEXT,
        cooking_time_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Ingredient Table
    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        image_url TEXT,
        category TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Collection Table
    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // Comment Table
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        recipe_id TEXT,
        content TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // CookingHistory Table
    await db.execute('''
      CREATE TABLE cooking_history (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        recipe_id TEXT,
        rating INTEGER,
        notes TEXT,
        cooked_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // UserActivity Table
    await db.execute('''
      CREATE TABLE user_activities (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        activity TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // UserFavorite Table (Many-to-Many between UserProfile and Recipe)
    await db.execute('''
      CREATE TABLE user_favorites (
        user_id TEXT,
        recipe_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // UserIngredient Table (Many-to-Many between UserProfile and Ingredient)
    await db.execute('''
      CREATE TABLE user_ingredients (
        user_id TEXT,
        ingredient_id TEXT,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, ingredient_id),
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // RecipeIngredient Table (Many-to-Many between Recipe and Ingredient)
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        recipe_id TEXT,
        ingredient_id TEXT,
        quantity TEXT NOT NULL,
        PRIMARY KEY (recipe_id, ingredient_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // Tag Table
    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // RecipeTag Table (Many-to-Many between Recipe and Tag)
    await db.execute('''
      CREATE TABLE recipe_tags (
        recipe_id TEXT,
        tag_id TEXT,
        PRIMARY KEY (recipe_id, tag_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // ViewHistory Table (User view recipe history)
    await db.execute('''
      CREATE TABLE view_history (
        user_id TEXT,
        recipe_id TEXT,
        last_viewed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Xử lý nâng cấp database nếu có thay đổi schema trong tương lai
  }

  // Common CRUD Operations
  Future<int> insert<T>(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> update<T>(String tableName, Map<String, dynamic> data, String idColumn) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: '$idColumn = ?',
      whereArgs: [data[idColumn]],
    );
  }

  Future<int> delete(String tableName, String id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Specific CRUD for UserProfile ---
  Future<int> insertUserProfile(UserProfile userProfile) async {
    final db = await database;
    return await db.insert('user_profiles', userProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfileById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  // --- Specific CRUD for Ingredient ---
  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await database;
    return await db.insert('ingredients', ingredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ingredient>> getIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');
    return List.generate(maps.length, (i) {
      return Ingredient.fromMap(maps[i]);
    });
  }

  // --- Phương thức CRUD cho UserIngredient ---
  Future<int> insertUserIngredient(UserIngredient userIngredient) async {
    final db = await database;
    userIngredient.addedAt = userIngredient.addedAt ?? DateTime.now();
    return await db.insert('user_ingredients', userIngredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

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

  Future<int> deleteUserIngredient(String userId, String ingredientId) async {
    final db = await database;
    return await db.delete(
      'user_ingredients',
      where: 'user_id = ? AND ingredient_id = ?',
      whereArgs: [userId, ingredientId],
    );
  }

}