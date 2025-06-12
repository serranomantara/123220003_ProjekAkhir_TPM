import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Import for desktop/web support
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/egg_product.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/order.dart' hide CartItem;

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

  // Table names (same as before)
  static const String tableEggProduct = 'egg_products';
  static const String tableUser = 'users';
  static const String tableCartItem = 'cart_items';
  static const String tableOrder = 'orders';
  static const String tableOrderItem = 'order_items';
  static const String tableFeedback = 'feedbacks';

  Future<Database> _initDb() async {
    // Initialize databaseFactory for different platforms
    if (kIsWeb) {
      // For web platform, use sqflite_common_ffi with IndexedDB
      databaseFactory = databaseFactoryFfi;
    } else {
      // For mobile/desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }

    final path = join(await getDatabasesPath(), 'egg_store.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Web-specific database initialization
  Future<Database> _initWebDb() async {
    // For web, we need to use a different approach
    databaseFactory = databaseFactoryFfi;
    final db = await databaseFactory.openDatabase('egg_store.db');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create egg_products table
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
        discount REAL DEFAULT 0.0,
        rating REAL DEFAULT 0.0,
        reviewCount INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE $tableUser (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        profileImageUrl TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create cart_items table
    await db.execute('''
      CREATE TABLE $tableCartItem (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES $tableUser (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES $tableEggProduct (id) ON DELETE CASCADE
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE $tableOrder (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        orderNumber TEXT UNIQUE NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT,
        paymentStatus TEXT,
        shippingAddress TEXT,
        notes TEXT,
        orderDate TEXT,
        deliveryDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES $tableUser (id) ON DELETE CASCADE
      )
    ''');

    // Create order_items table
    await db.execute('''
      CREATE TABLE $tableOrderItem (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES $tableOrder (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES $tableEggProduct (id)
      )
    ''');

    // Create feedbacks table
    await db.execute('''
      CREATE TABLE $tableFeedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kesan TEXT NOT NULL,
        pesan TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_cart_user ON $tableCartItem (userId)');
    await db.execute('CREATE INDEX idx_order_user ON $tableOrder (userId)');
    await db.execute(
      'CREATE INDEX idx_order_item_order ON $tableOrderItem (orderId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableCartItem ADD COLUMN productName TEXT DEFAULT ''
      ''');

      await db.execute('''
        UPDATE $tableCartItem 
        SET productName = (
          SELECT name FROM $tableEggProduct 
          WHERE $tableEggProduct.id = $tableCartItem.productId
        )
        WHERE productName = '' OR productName IS NULL
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $tableFeedback (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kesan TEXT NOT NULL,
          pesan TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }
  }

  // Helper method to convert EggProduct to Map for database
  Map<String, dynamic> _eggProductToMap(EggProduct product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'imageUrl': product.imageUrl,
      'category': product.category,
      'weight': product.weight,
      'harvestDate': product.harvestDate?.toIso8601String(),
      'farmOrigin': product.farmOrigin,
      'isOrganic': product.isOrganic ? 1 : 0,
      'discount': product.discount ?? 0.0,
      'rating': product.rating ?? 0.0,
      'reviewCount': product.reviewCount ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Helper method to convert Map from database to EggProduct
  EggProduct _mapToEggProduct(Map<String, dynamic> map) {
    return EggProduct(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      imageUrl: map['imageUrl'] as String,
      category: map['category'] as String,
      weight: (map['weight'] as num?)?.toDouble(),
      harvestDate: map['harvestDate'] != null
          ? DateTime.tryParse(map['harvestDate'] as String)
          : null,
      farmOrigin: map['farmOrigin'] as String? ?? 'Lokal',
      isOrganic: (map['isOrganic'] as int) == 1,
      discount: (map['discount'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
    );
  }

  // ==================== EGG PRODUCT METHODS ====================

  Future<int> insertProduct(EggProduct product) async {
    final dbClient = await db;
    return await dbClient.insert(
      tableEggProduct,
      _eggProductToMap(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EggProduct>> getAllProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.query(
      tableEggProduct,
      orderBy: 'name ASC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<EggProduct?> getProductById(String id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return _mapToEggProduct(result.first);
    }
    return null;
  }

  Future<List<EggProduct>> getProductsByCategory(String category) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<List<EggProduct>> searchProducts(String searchTerm) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'name LIKE ? OR description LIKE ? OR category LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%', '%$searchTerm%'],
      orderBy: 'name ASC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<List<EggProduct>> getProductsOnDiscount() async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'discount > 0',
      orderBy: 'discount DESC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<List<EggProduct>> getOrganicProducts() async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'isOrganic = 1',
      orderBy: 'name ASC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<int> updateProduct(EggProduct product) async {
    final dbClient = await db;
    final map = _eggProductToMap(product);
    map['updatedAt'] = DateTime.now().toIso8601String();

    return await dbClient.update(
      tableEggProduct,
      map,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      tableEggProduct,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== USER METHODS ====================

  Future<int> insertUser(User user) async {
    final dbClient = await db;
    return await dbClient.insert(
      tableUser,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserById(String id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableUser,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableUser,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final dbClient = await db;
    return await dbClient.update(
      tableUser,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final dbClient = await db;
    return await dbClient.delete(tableUser, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CART ITEM METHODS ====================

  Future<int> insertCartItem(CartItem cartItem) async {
    final dbClient = await db;
    return await dbClient.insert(
      tableCartItem,
      cartItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> getCartItemsByUserId(String userId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableCartItem,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => CartItem.fromMap(json)).toList();
  }

  Future<CartItem?> getCartItem(String userId, String productId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableCartItem,
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );
    return result.isNotEmpty ? CartItem.fromMap(result.first) : null;
  }

  Future<int> updateCartItem(CartItem cartItem) async {
    final dbClient = await db;
    return await dbClient.update(
      tableCartItem,
      cartItem.toMap(),
      where: 'id = ?',
      whereArgs: [cartItem.id],
    );
  }

  Future<int> deleteCartItem(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      tableCartItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart(String userId) async {
    final dbClient = await db;
    return await dbClient.delete(
      tableCartItem,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ==================== ORDER METHODS ====================

  Future<int> insertOrder(Order order) async {
    final dbClient = await db;
    return await dbClient.insert(
      tableOrder,
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableOrder,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<Order?> getOrderById(String id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableOrder,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Order.fromMap(result.first);
    }
    return null;
  }

  Future<Order?> getOrderByOrderNumber(String orderNumber) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableOrder,
      where: 'orderNumber = ?',
      whereArgs: [orderNumber],
    );

    if (result.isNotEmpty) {
      return Order.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateOrder(Order order) async {
    final dbClient = await db;
    return await dbClient.update(
      tableOrder,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(String id) async {
    final dbClient = await db;
    return await dbClient.delete(tableOrder, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== FEEDBACK METHODS ====================

  Future<int> insertFeedback(
    String kesan,
    String pesan,
    String timestamp,
  ) async {
    final dbClient = await db;
    return await dbClient.insert(tableFeedback, {
      'kesan': kesan,
      'pesan': pesan,
      'timestamp': timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final dbClient = await db;
    return await dbClient.query(tableFeedback, orderBy: 'timestamp DESC');
  }

  // ==================== UTILITY METHODS ====================

  Future<int> getProductCount() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT COUNT(*) FROM $tableEggProduct',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getUserCount() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('SELECT COUNT(*) FROM $tableUser');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getOrderCount() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('SELECT COUNT(*) FROM $tableOrder');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalRevenue() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT SUM(totalAmount) FROM $tableOrder WHERE status = ?',
      ['completed'],
    );
    return (result.first.values.first as double?) ?? 0.0;
  }

  Future<List<EggProduct>> getLowStockProducts({int threshold = 10}) async {
    final dbClient = await db;
    final result = await dbClient.query(
      tableEggProduct,
      where: 'stock < ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );

    return result.map((json) => _mapToEggProduct(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getMonthlySales() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT 
        strftime('%Y-%m', orderDate) as month,
        COUNT(*) as orderCount,
        SUM(totalAmount) as totalRevenue
      FROM $tableOrder 
      WHERE status = 'completed'
      GROUP BY strftime('%Y-%m', orderDate)
      ORDER BY month DESC
      LIMIT 12
    ''');

    return result;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final dbClient = await db;
    await dbClient.delete(tableOrderItem);
    await dbClient.delete(tableOrder);
    await dbClient.delete(tableCartItem);
    await dbClient.delete(tableFeedback);
    await dbClient.delete(tableUser);
    await dbClient.delete(tableEggProduct);
  }

  // Close database
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  // Transaction example for creating order with items
  Future<bool> createOrderWithItems(
    Order order,
    List<CartItem> cartItems,
  ) async {
    final dbClient = await db;

    try {
      await dbClient.transaction((txn) async {
        // Insert order
        await txn.insert(tableOrder, order.toMap());

        // Insert order items and update product stock
        for (var cartItem in cartItems) {
          final orderItem = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'orderId': order.id,
            'productId': cartItem.productId,
            'productName': cartItem.productName,
            'quantity': cartItem.quantity,
            'price': cartItem.price,
            'subtotal': cartItem.quantity * cartItem.price,
          };

          await txn.insert(tableOrderItem, orderItem);

          // Update product stock
          await txn.rawUpdate(
            'UPDATE $tableEggProduct SET stock = stock - ? WHERE id = ?',
            [cartItem.quantity, cartItem.productId],
          );
        }

        // Clear user's cart
        await txn.delete(
          tableCartItem,
          where: 'userId = ?',
          whereArgs: [order.userId],
        );
      });

      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    final dbClient = await db;

    // Check if products already exist
    final count = await getProductCount();
    if (count > 0) return; // Data already exists

    // Insert sample products
    final sampleProducts = [
      EggProduct(
        id: '1',
        name: 'Telur Ayam Kampung Super',
        description:
            'Telur ayam kampung berkualitas tinggi dari peternakan organik',
        price: 35000,
        stock: 50,
        imageUrl: 'assets/images/premium_egg.jpg',
        category: 'premium',
        weight: 60,
        harvestDate: DateTime.now().subtract(const Duration(days: 2)),
        farmOrigin: 'Peternakan Jaya Abadi',
        isOrganic: true,
        rating: 4.8,
        reviewCount: 120,
      ),
      EggProduct(
        id: '2',
        name: 'Telur Ayam Negeri',
        description: 'Telur ayam negeri segar dengan harga terjangkau',
        price: 25000,
        stock: 200,
        imageUrl: 'assets/images/regular_egg.jpg',
        category: 'regular',
        weight: 55,
        harvestDate: DateTime.now().subtract(const Duration(days: 1)),
        farmOrigin: 'Peternakan Sejahtera',
        isOrganic: false,
        discount: 10,
        rating: 4.2,
        reviewCount: 85,
      ),
      EggProduct(
        id: '3',
        name: 'Telur Bebek Premium',
        description:
            'Telur bebek ukuran besar dengan kuning telur yang kaya nutrisi',
        price: 45000,
        stock: 30,
        imageUrl: 'assets/images/duck_egg.jpg',
        category: 'premium',
        weight: 80,
        harvestDate: DateTime.now().subtract(const Duration(days: 3)),
        farmOrigin: 'Peternakan Bebek Bahagia',
        isOrganic: true,
        rating: 4.9,
        reviewCount: 65,
      ),
    ];

    for (var product in sampleProducts) {
      await insertProduct(product);
    }
  }
}
