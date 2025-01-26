class AppUser {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? password;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.password,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      name: data['name'],
      password: data['passsword'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      if (name != null) 'name': name,
      if (password != null) 'password': password,
    };
  }
}
