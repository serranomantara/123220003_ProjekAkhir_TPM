class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  // Convert User object to Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  // Convert Map dari SharedPreferences menjadi User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
    );
  }
}