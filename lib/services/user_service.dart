import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _usersKey = 'users';
  static const String _loggedInKey = 'logged_in_user';

  static Future<dynamic> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    if (users.any((u) => u.split(':')[0] == username)) {
      return 'Username already exists';
    }
    users.add('$username:$password');
    await prefs.setStringList(_usersKey, users);
    return true;
  }

  static Future<dynamic> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    final found = users.any((u) {
      final parts = u.split(':');
      return parts[0] == username && parts[1] == password;
    });
    if (found) {
      await prefs.setString(_loggedInKey, username);
      return true;
    }
    return 'Invalid username or password';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  static Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedInKey);
  }
}
