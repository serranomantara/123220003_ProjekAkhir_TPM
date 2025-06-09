import 'package:flutter/foundation.dart';

/// Model untuk produk telur
class EggProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final double? weight; // dalam gram (opsional)
  final DateTime? harvestDate;
  final String farmOrigin;
  final bool isOrganic;
  final double? discount; // diskon dalam persen (0-100)
  final double? rating; // rating 1-5 (opsional)
  final int? reviewCount;

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
  });

  /// Harga setelah diskon
  double get discountedPrice {
    if (discount == null || discount == 0) return price;
    return price * (1 - discount! / 100);
  }

  /// Apakah produk sedang diskon
  bool get isOnDiscount => discount != null && discount! > 0;

  /// Apakah stok hampir habis
  bool get isLowStock => stock < 10;

  /// Konversi dari JSON (untuk API)
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
          ? DateTime.tryParse(json['harvestDate'])
          : null,
      farmOrigin: json['farmOrigin'] ?? 'Lokal',
      isOrganic: json['isOrganic'] ?? false,
      discount: (json['discount'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }

  /// Konversi ke JSON (untuk API)
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
    };
  }

  /// Konversi ke Map (untuk SQLite)
  Map<String, dynamic> toMap() => toJson();

  /// Konversi dari Map (untuk SQLite)
  factory EggProduct.fromMap(Map<String, dynamic> map) => EggProduct.fromJson(map);

  /// Copy dengan perubahan
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
    );
  }

  @override
  String toString() =>
      'EggProduct{id: $id, name: $name, price: $price, stock: $stock}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EggProduct && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

/// Enum untuk kategori produk telur
enum EggCategory {
  chickenRegular('Ayam Biasa'),
  chickenOrganic('Ayam Organik'),
  duck('Bebek'),
  quail('Puyuh'),
  other('Lainnya');

  final String displayName;
  const EggCategory(this.displayName);
}

/// Dummy data untuk pengujian / pengembangan
List<EggProduct> dummyEggProducts = [
  EggProduct(
    id: '1',
    name: 'Telur Ayam Kampung Super',
    description: 'Telur ayam kampung berkualitas tinggi dari peternakan organik',
    price: 35000,
    stock: 50,
    imageUrl: 'https://example.com/images/premium_egg.jpg',
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
    imageUrl: 'https://example.com/images/regular_egg.jpg',
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
    description: 'Telur bebek ukuran besar dengan kuning telur yang kaya nutrisi',
    price: 45000,
    stock: 30,
    imageUrl: 'https://example.com/images/duck_egg.jpg',
    category: 'premium',
    weight: 80,
    harvestDate: DateTime.now().subtract(const Duration(days: 3)),
    farmOrigin: 'Peternakan Bebek Bahagia',
    isOrganic: true,
    rating: 4.9,
    reviewCount: 65,
  ),
];
