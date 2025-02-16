class AppUser {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? password;
  final bool? approved;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.password,
    this.approved,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      name: data['name'],
      password: data['password'],
      approved: data['approved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      if (name != null) 'name': name,
      if (password != null) 'password': password,
      if (approved != null) 'approved': approved,
    };
  }
}
