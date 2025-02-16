class BrandUser {
  final String uid;
  final String name;
  final String email;
  final String? logoUrl;
  final String status;
  final String? description;
  final dynamic shippingInfo;
  final String? contact;
  final String? country;
  final String? rejectionReason;
  final String? password;

  BrandUser({
    required this.uid,
    required this.name,
    required this.email,
    this.logoUrl,
    required this.status,
    this.description,
    this.shippingInfo,
    this.contact,
    this.country,
    this.rejectionReason,
    this.password,
  });

  factory BrandUser.fromMap(String uid, Map<String, dynamic> data) {
    return BrandUser(
      uid: uid,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      logoUrl: data['logoUrl']?.toString(),
      status: data['status']?.toString() ?? 'pending',
      description: data['description']?.toString(),
      shippingInfo: data['shippingInfo'] ?? [],
      contact: data['contact']?.toString(),
      country: data['country']?.toString(),
      rejectionReason: data['rejectionReason']?.toString(),
      password: data['password']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'status': status,
      if (description != null) 'description': description,
      if (shippingInfo != null) 'shippingInfo': shippingInfo,
      if (contact != null) 'contact': contact,
      if (country != null) 'country': country,
      if (rejectionReason != null) "rejectionReason": rejectionReason,
      if (password != null) 'password': password,
    };
  }
}
