// lib/api/egg_store_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/egg_product.dart';

class EggStoreApi {
  static const String _baseUrl = 'https://api.eggstore.example.com/v1';
  final http.Client _client;

  EggStoreApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<EggProduct>> fetchProducts({
    String? category,
    String? farmOrigin,
    double? minPrice,
    double? maxPrice,
    bool? isOrganic,
    String? searchQuery,
  }) async {
    try {
      // Build query parameters
      final params = <String, String>{};
      if (category != null) params['category'] = category;
      if (farmOrigin != null) params['farmOrigin'] = farmOrigin;
      if (minPrice != null) params['minPrice'] = minPrice.toString();
      if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
      if (isOrganic != null) params['isOrganic'] = isOrganic.toString();
      if (searchQuery != null) params['search'] = searchQuery;

      final uri = Uri.parse(
        '$_baseUrl/products',
      ).replace(queryParameters: params);

      await Future.delayed(const Duration(milliseconds: 500));

      return _mockProducts.where((product) {
        if (category != null && product.category != category) return false;
        if (farmOrigin != null && product.farmOrigin != farmOrigin)
          return false;
        if (minPrice != null && product.price < minPrice) return false;
        if (maxPrice != null && product.price > maxPrice) return false;
        if (isOrganic != null && product.isOrganic != isOrganic) return false;
        if (searchQuery != null &&
            !product.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<EggProduct> getProductDetail(String productId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // In a real app:
      // final response = await _client.get(Uri.parse('$_baseUrl/products/$productId'));
      // if (response.statusCode == 200) {
      //   return EggProduct.fromJson(json.decode(response.body));
      // } else {
      //   throw Exception('Failed to load product details');
      // }

      // Mock implementation
      final product = _mockProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      return product;
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }

  Future<String> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(String userId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'orderId': 'ORD-001',
          'date': '2023-05-15',
          'items': [
            {
              'productId': '1',
              'quantity': 2,
              'price': 30000,
              'name': 'Telur Ayam Kampung',
            },
            {
              'productId': '3',
              'quantity': 1,
              'price': 35000,
              'name': 'Telur Bebek',
            },
          ],
          'total': 95000,
          'status': 'completed',
          'deliveryAddress': 'Jl. Contoh No. 123, Jakarta',
        },
        {
          'orderId': 'ORD-002',
          'date': '2023-06-01',
          'items': [
            {
              'productId': '2',
              'quantity': 5,
              'price': 25000,
              'name': 'Telur Ayam Negeri',
            },
          ],
          'total': 125000,
          'status': 'processing',
          'deliveryAddress': 'Jl. Contoh No. 123, Jakarta',
        },
      ];
    } catch (e) {
      throw Exception('Failed to get order history: $e');
    }
  }

  final List<EggProduct> _mockProducts = [
    EggProduct(
      id: '1',
      name: 'Telur Ayam Kampung Super',
      description:
          'Telur ayam kampung berkualitas tinggi dari peternakan organik. Kandungan nutrisi lebih tinggi dibanding telur biasa.',
      price: 35000,
      stock: 50,
      imageUrl: 'assets/images/telur_ayam_super.jpeg',
      category: 'Ayam Organik',
      weight: 60,
      harvestDate: DateTime.now().subtract(const Duration(days: 2)),
      farmOrigin: 'Peternakan Jaya Abadi',
      isOrganic: true,
      discount: 0,
      rating: 4.8,
      reviewCount: 120,
    ),
    EggProduct(
      id: '2',
      name: 'Telur Ayam Negeri',
      description:
          'Telur ayam negeri segar dengan harga terjangkau. Cocok untuk konsumsi sehari-hari.',
      price: 25000,
      stock: 200,
      imageUrl: 'assets/images/telur_ayam_negeri.jpeg',
      category: 'Ayam Biasa',
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
          'Telur bebek ukuran besar dengan kuning telur yang kaya nutrisi. Ideal untuk membuat martabak atau kue.',
      price: 45000,
      stock: 30,
      imageUrl: 'assets/images/telur_bebek.jpeg',
      category: 'Bebek',
      weight: 80,
      harvestDate: DateTime.now().subtract(const Duration(days: 3)),
      farmOrigin: 'Peternakan Bebek Bahagia',
      isOrganic: true,
      discount: 5,
      rating: 4.9,
      reviewCount: 65,
    ),
    EggProduct(
      id: '4',
      name: 'Telur Puyuh',
      description:
          'Telur puyuh dengan ukuran kecil namun kaya protein. Sering digunakan untuk sate atau campuran makanan.',
      price: 15000,
      stock: 100,
      imageUrl: 'assets/images/telur_puyuh.jpeg',
      category: 'Puyuh',
      weight: 10,
      harvestDate: DateTime.now().subtract(const Duration(days: 1)),
      farmOrigin: 'Peternakan Sejahtera',
      isOrganic: false,
      discount: 0,
      rating: 4.0,
      reviewCount: 42,
    ),
    EggProduct(
      id: '5',
      name: 'Telur Omega-3',
      description:
          'Telur ayam dengan kandungan omega-3 tinggi. Diproduksi dari ayam yang diberi pakan khusus.',
      price: 40000,
      stock: 40,
      imageUrl: 'assets/images/telur_omega.jpg',
      category: 'Ayam Organik',
      weight: 60,
      harvestDate: DateTime.now().subtract(const Duration(days: 2)),
      farmOrigin: 'Peternakan Jaya Abadi',
      isOrganic: true,
      discount: 15,
      rating: 4.7,
      reviewCount: 93,
    ),
  ];
}
