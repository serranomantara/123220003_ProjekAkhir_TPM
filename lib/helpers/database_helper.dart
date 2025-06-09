import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/egg_product.dart';
import '../pages/home_page.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static const String tableEggProduct = 'egg_products';

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'egg_store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableEggProduct (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        weight REAL,
        harvestDate TEXT,
        farmOrigin TEXT,
        isOrganic INTEGER NOT NULL,
        discount REAL,
        rating REAL,
        reviewCount INTEGER
      )
    ''');
  }

  // Insert product
  Future<int> insertProduct(EggProduct product) async {
    final dbClient = await db;
    return await dbClient.insert(
      tableEggProduct,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all products
  Future<List<EggProduct>> getAllProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result =
        await dbClient.query(tableEggProduct);

    return result.map((json) => EggProduct.fromMap(json)).toList();
  }

  // Get product by ID
  Future<EggProduct?> getProductById(String id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return EggProduct.fromMap(result.first);
    }
    return null;
  }

  // Update product
  Future<int> updateProduct(EggProduct product) async {
    final dbClient = await db;
    return await dbClient.update(
      tableEggProduct,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<int> deleteProduct(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      tableEggProduct,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all products
  Future<int> deleteAllProducts() async {
    final dbClient = await db;
    return await dbClient.delete(tableEggProduct);
  }

  // Count products
  Future<int> getProductCount() async {
    final dbClient = await db;
    final x = await dbClient.rawQuery('SELECT COUNT(*) FROM $tableEggProduct');
    return Sqflite.firstIntValue(x) ?? 0;
  }

  // Close DB
  Future<void> close() async {
    final dbClient = await db;
    await dbClient.close();
  }
}
