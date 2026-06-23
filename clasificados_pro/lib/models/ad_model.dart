/// Modelo de Anuncio (Ad)
/// Representa un clasificado completo con toda su información

class AdModel {
  final String id;
  final String title;
  final String description;
  final String category; // Servicios, Transporte, Bienes, Empleos
  final String subcategory;
  final double price;
  final String currency;
  final String userId;
  final String userName;
  final String userPhone;
  
  // Ubicación Híbrida
  final String country;
  final String state;
  final String city;
  final double? latitude;
  final double? longitude;
  
  // Ciclo de Vida
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isExpired;
  final bool isBumped; // Premium: Anuncio destacado
  
  // Multimedia
  final List<String> imageUrls;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.price,
    this.currency = 'USD',
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.country,
    required this.state,
    required this.city,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.expiresAt,
    this.isExpired = false,
    this.isBumped = false,
    this.imageUrls = const [],
  });

  /// Calcula días restantes para expiración
  int get daysRemaining {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// Determina si está próximo a expirar (menos de 3 días)
  bool get needsRenewal => daysRemaining <= 3 && !isExpired;

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      subcategory: json['subcategory'],
      price: (json['price'] as num).toDouble(),
      userId: json['user_id'],
      userName: json['user_name'],
      userPhone: json['user_phone'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isExpired: json['is_expired'] ?? false,
      isBumped: json['is_bumped'] ?? false,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'currency': currency,
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'country': country,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_expired': isExpired,
      'is_bumped': isBumped,
      'image_urls': imageUrls,
    };
  }
}
