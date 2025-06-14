import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserService {
  static const String _usersKey = 'users';
  static const String _loggedInKey = 'logged_in_user';

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<dynamic> register(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      if (users.any((u) => u.split(':')[0] == username)) {
        return 'Username sudah digunakan';
      }

      if (username.isEmpty || password.isEmpty) {
        return 'Username dan password tidak boleh kosong';
      }

      if (username.length < 3) {
        return 'Username minimal 3 karakter';
      }

      if (password.length < 6) {
        return 'Password minimal 6 karakter';
      }

      final hashedPassword = _hashPassword(password);
      users.add('$username:$hashedPassword');
      await prefs.setStringList(_usersKey, users);

      return true;
    } catch (e) {
      return 'Terjadi kesalahan saat registrasi';
    }
  }

  static Future<dynamic> login(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      // Validasi input
      if (username.isEmpty || password.isEmpty) {
        return 'Username dan password tidak boleh kosong';
      }

      // Hash password yang diinput untuk dibandingkan
      final hashedPassword = _hashPassword(password);

      // Cari user dengan username dan hash password yang cocok
      final found = users.any((u) {
        final parts = u.split(':');
        return parts.length >= 2 &&
            parts[0] == username &&
            parts[1] == hashedPassword;
      });

      if (found) {
        await prefs.setString(_loggedInKey, username);
        return true;
      }

      return 'Username atau password salah';
    } catch (e) {
      return 'Terjadi kesalahan saat login';
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInKey);
    } catch (e) {
      // Handle error jika diperlukan
      print('Error during logout: $e');
    }
  }

  static Future<String?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_loggedInKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCurrentUserName() async {
    return await getLoggedInUser();
  }

  static Future<dynamic> changePassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      if (newPassword.length < 6) {
        return 'Password baru minimal 6 karakter';
      }

      final oldHashedPassword = _hashPassword(oldPassword);
      final newHashedPassword = _hashPassword(newPassword);

      for (int i = 0; i < users.length; i++) {
        final parts = users[i].split(':');
        if (parts.length >= 2 &&
            parts[0] == username &&
            parts[1] == oldHashedPassword) {
          users[i] = '$username:$newHashedPassword';
          await prefs.setStringList(_usersKey, users);
          return true;
        }
      }

      return 'Password lama tidak cocok';
    } catch (e) {
      return 'Terjadi kesalahan saat mengubah password';
    }
  }

  static Future<void> clearAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_loggedInKey);
    } catch (e) {
      print('Error clearing users: $e');
    }
  }

  static Future<int> getUserCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];
      return users.length;
    } catch (e) {
      return 0;
    }
  }
}
