import 'package:shared_preferences/shared_preferences.dart';
import '../models/egg_product.dart';
import 'dart:convert';

class SharedPreferencesService {
  // Keys
  static const String _keyUsername = 'username';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyFavorites = 'favorites';

  // Auth Functions
  Future<void> saveLoginData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Favorite Functions
  Future<void> addFavorite(EggProduct product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.add(product);
    await prefs.setString(
      _keyFavorites,
      jsonEncode(favorites.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((product) => product.id == id);
    await prefs.setString(
      _keyFavorites,
      jsonEncode(favorites.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<EggProduct>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_keyFavorites);
    if (favoritesJson == null) return [];

    final List<dynamic> jsonList = jsonDecode(favoritesJson);
    return jsonList.map((json) => EggProduct.fromJson(json)).toList();
  }

  Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.any((product) => product.id == id);
  }
}
