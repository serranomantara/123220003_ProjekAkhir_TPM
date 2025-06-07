import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/egg_product.dart';

class EggStoreApi {
  static const String baseUrl = 'https://681388b3129f6313e2119693.mockapi.io/api/v1';

  // Mendapatkan daftar produk telur
  Future<List<EggProduct>> fetchProducts({String? category, String? farm}) async {
    try {
      String query = '';
      if (category != null) query += 'category=$category&';
      if (farm != null) query += 'farm=$farm&';
      query = query.isNotEmpty ? '?' + query.substring(0, query.length - 1) : '';

      final response = await http.get(Uri.parse('$baseUrl/eggs$query'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => EggProduct.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat produk telur');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mendapatkan detail produk telur berdasarkan ID
  Future<EggProduct> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/eggs/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return EggProduct.fromJson(jsonData);
      } else {
        throw Exception('Gagal memuat detail produk');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
