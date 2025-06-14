import 'package:flutter/foundation.dart';

class EggProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final double? weight; 
  final DateTime? harvestDate;
  final String farmOrigin;
  final bool isOrganic;
  final double? discount; 
  final double? rating; 
  final int? reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? assetImagePath; 

  EggProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    this.weight,
    this.harvestDate,
    this.farmOrigin = 'Lokal',
    this.isOrganic = false,
    this.discount,
    this.rating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
    this.assetImagePath,
  });

  String? get assetImage => assetImagePath;

  String get displayImage => assetImage ?? imageUrl;

  double get discountedPrice {
    if (discount == null || discount == 0) return price;
    return price * (1 - discount! / 100);
  }

  bool get isOnDiscount => discount != null && discount! > 0;

  bool get isLowStock => stock < 10;

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get formattedDiscountedPrice {
    return 'Rp ${discountedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  factory EggProduct.fromJson(Map<String, dynamic> json) {
    return EggProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      harvestDate: json['harvestDate'] != null
          ? DateTime.tryParse(json['harvestDate'] as String)
          : null,
      farmOrigin: json['farmOrigin'] as String? ?? 'Lokal',
      isOrganic: json['isOrganic'] as bool? ?? false,
      discount: (json['discount'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
      'weight': weight,
      'harvestDate': harvestDate?.toIso8601String(),
      'farmOrigin': farmOrigin,
      'isOrganic': isOrganic,
      'discount': discount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
      'weight': weight,
      'harvestDate': harvestDate?.toIso8601String(),
      'farmOrigin': farmOrigin,
      'isOrganic': isOrganic ? 1 : 0,
      'discount': discount ?? 0.0,
      'rating': rating ?? 0.0,
      'reviewCount': reviewCount ?? 0,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory EggProduct.fromMap(Map<String, dynamic> map) {
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
      isOrganic: (map['isOrganic'] as int?) == 1,
      discount: (map['discount'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  EggProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    double? weight,
    DateTime? harvestDate,
    String? farmOrigin,
    bool? isOrganic,
    double? discount,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assetImagePath,
  }) {
    return EggProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      harvestDate: harvestDate ?? this.harvestDate,
      farmOrigin: farmOrigin ?? this.farmOrigin,
      isOrganic: isOrganic ?? this.isOrganic,
      discount: discount ?? this.discount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assetImagePath: assetImagePath ?? this.assetImagePath,
    );
  }

  EggProduct updateStock(int newStock) {
    return copyWith(stock: newStock, updatedAt: DateTime.now());
  }

  EggProduct reduceStock(int quantity) {
    final newStock = stock - quantity;
    if (newStock < 0) {
      throw Exception(
        'Stock tidak mencukupi. Stock tersedia: $stock, diminta: $quantity',
      );
    }
    return copyWith(stock: newStock, updatedAt: DateTime.now());
  }

  EggProduct addStock(int quantity) {
    return copyWith(stock: stock + quantity, updatedAt: DateTime.now());
  }

  EggProduct updateRating(double newRating) {
    final currentReviewCount = reviewCount ?? 0;
    final currentRating = rating ?? 0.0;

    final totalRating = (currentRating * currentReviewCount) + newRating;
    final newReviewCount = currentReviewCount + 1;
    final avgRating = totalRating / newReviewCount;

    return copyWith(
      rating: double.parse(avgRating.toStringAsFixed(1)),
      reviewCount: newReviewCount,
      updatedAt: DateTime.now(),
    );
  }

  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        description.isNotEmpty &&
        price > 0 &&
        stock >= 0 &&
        (imageUrl.isNotEmpty || assetImagePath != null) &&
        category.isNotEmpty &&
        farmOrigin.isNotEmpty;
  }

  List<String> get validationErrors {
    List<String> errors = [];

    if (id.isEmpty) errors.add('ID tidak boleh kosong');
    if (name.isEmpty) errors.add('Nama produk tidak boleh kosong');
    if (description.isEmpty) errors.add('Deskripsi tidak boleh kosong');
    if (price <= 0) errors.add('Harga harus lebih dari 0');
    if (stock < 0) errors.add('Stock tidak boleh negatif');
    if (imageUrl.isEmpty && assetImagePath == null) {
      errors.add('Harap sediakan URL gambar atau asset gambar');
    }
    if (category.isEmpty) errors.add('Kategori tidak boleh kosong');
    if (farmOrigin.isEmpty) errors.add('Asal peternakan tidak boleh kosong');
    if (discount != null && (discount! < 0 || discount! > 100)) {
      errors.add('Diskon harus antara 0-100%');
    }
    if (rating != null && (rating! < 0 || rating! > 5)) {
      errors.add('Rating harus antara 0-5');
    }
    if (weight != null && weight! <= 0) {
      errors.add('Berat harus lebih dari 0');
    }

    return errors;
  }

  @override
  String toString() =>
      'EggProduct{id: $id, name: $name, price: $price, stock: $stock, category: $category, isOrganic: $isOrganic}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggProduct &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price);

  @override
  int get hashCode => Object.hash(id, name, price);
}

enum EggCategory {
  chickenRegular('regular', 'Ayam Biasa'),
  chickenPremium('premium', 'Ayam Premium'),
  chickenOrganic('organic', 'Ayam Organik'),
  duck('duck', 'Bebek'),
  quail('quail', 'Puyuh'),
  other('other', 'Lainnya');

  final String value;
  final String displayName;
  const EggCategory(this.value, this.displayName);

  static EggCategory fromValue(String value) {
    return EggCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => EggCategory.other,
    );
  }
}

enum StockStatus {
  available('Tersedia'),
  lowStock('Stok Terbatas'),
  outOfStock('Habis');

  final String displayName;
  const StockStatus(this.displayName);

  static StockStatus fromStock(int stock) {
    if (stock == 0) return StockStatus.outOfStock;
    if (stock < 10) return StockStatus.lowStock;
    return StockStatus.available;
  }
}

extension EggProductExtension on EggProduct {
  StockStatus get stockStatus => StockStatus.fromStock(stock);

  bool get isNew {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays <= 7;
  }

  int get ageInDays {
    if (harvestDate == null) return 0;
    return DateTime.now().difference(harvestDate!).inDays;
  }

  bool get isFresh => ageInDays <= 7;

  String get freshnessLevel {
    if (ageInDays <= 3) return 'Sangat Segar';
    if (ageInDays <= 7) return 'Segar';
    if (ageInDays <= 14) return 'Baik';
    return 'Kurang Segar';
  }
}

List<EggProduct> dummyEggProducts = [
  EggProduct(
    id: '1',
    name: 'Telur Ayam Kampung Super',
    description:
        'Telur ayam kampung berkualitas tinggi dari peternakan organik. Telur ini dipanen langsung dari ayam kampung yang dipelihara secara alami tanpa antibiotik.',
    price: 35000,
    stock: 50,
    imageUrl: 'https://example.com/telur_ayam_super.jpg',
    category: 'premium',
    weight: 60,
    harvestDate: DateTime.now().subtract(const Duration(days: 2)),
    farmOrigin: 'Peternakan Jaya Abadi, Bogor',
    isOrganic: true,
    rating: 4.8,
    reviewCount: 120,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    assetImagePath: 'assets/telur_ayam_super.jpeg',
  ),
  EggProduct(
    id: '2',
    name: 'Telur Ayam Negeri',
    description:
        'Telur ayam negeri segar dengan harga terjangkau. Cocok untuk kebutuhan sehari-hari keluarga dengan kualitas terjamin.',
    price: 25000,
    stock: 200,
    imageUrl: 'https://example.com/telur_ayam_negeri.jpg',
    category: 'regular',
    weight: 55,
    harvestDate: DateTime.now().subtract(const Duration(days: 1)),
    farmOrigin: 'Peternakan Sejahtera, Depok',
    isOrganic: false,
    discount: 10,
    rating: 4.2,
    reviewCount: 85,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    assetImagePath: 'assets/telur_ayam_negeri.jpeg',
  ),
  EggProduct(
    id: '3',
    name: 'Telur Bebek Premium',
    description:
        'Telur bebek ukuran besar dengan kuning telur yang kaya nutrisi. Sangat baik untuk membuat kue dan makanan tradisional.',
    price: 45000,
    stock: 30,
    imageUrl: 'https://example.com/telur_bebek.jpg',
    category: 'premium',
    weight: 80,
    harvestDate: DateTime.now().subtract(const Duration(days: 3)),
    farmOrigin: 'Peternakan Bebek Bahagia, Tangerang',
    isOrganic: true,
    rating: 4.9,
    reviewCount: 65,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    assetImagePath: 'assets/telur_bebek.jpeg',
  ),
  EggProduct(
    id: '4',
    name: 'Telur Puyuh Organik',
    description:
        'Telur puyuh organik kecil namun kaya akan nutrisi. Sangat baik untuk anak-anak dan orang tua.',
    price: 15000,
    stock: 100,
    imageUrl: 'https://example.com/telur_puyuh.jpg',
    category: 'organic',
    weight: 15,
    harvestDate: DateTime.now().subtract(const Duration(days: 1)),
    farmOrigin: 'Peternakan Puyuh Sehat, Jakarta',
    isOrganic: true,
    discount: 5,
    rating: 4.6,
    reviewCount: 45,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    assetImagePath: 'assets/telur_puyuh.jpeg',
  ),
  EggProduct(
    id: '5',
    name: 'Telur Ayam Omega-3',
    description:
        'Telur ayam yang diperkaya dengan omega-3 untuk kesehatan jantung dan otak. Ayam diberi pakan khusus kaya omega-3.',
    price: 40000,
    stock: 5, // Low stock
    imageUrl: 'https://example.com/telur_omega.jpg',
    category: 'premium',
    weight: 65,
    harvestDate: DateTime.now().subtract(const Duration(days: 2)),
    farmOrigin: 'Peternakan Nutrisi Plus, Bekasi',
    isOrganic: false,
    discount: 15,
    rating: 4.7,
    reviewCount: 38,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    assetImagePath: 'assets/telur_omega.jpg',
  ),
];
