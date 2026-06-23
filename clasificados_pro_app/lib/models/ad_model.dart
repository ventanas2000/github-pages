/// Modelo principal para Anuncios (Ads)
class AdModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final String currency;
  final String userId;
  final String userName;
  final bool isPro;
  
  // Ubicación
  final String country;
  final String state;
  final String city;
  final double? latitude;
  final double? longitude;
  
  // Fechas
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isExpired;
  final bool isBumped;
  
  // Multimedia
  final List<String> imageUrls;
  final String primaryImageUrl;
  
  // Contacto
  final String phoneNumber;
  final String? email;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.currency = 'USD',
    required this.userId,
    required this.userName,
    this.isPro = false,
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
    this.primaryImageUrl = '',
    required this.phoneNumber,
    this.email,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      isPro: json['is_pro'] ?? false,
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isExpired: json['is_expired'] ?? false,
      isBumped: json['is_bumped'] ?? false,
      imageUrls: List<String>.from(json['images'] ?? []),
      primaryImageUrl: json['primary_image'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'price': price,
      'currency': currency,
      'user_id': userId,
      'user_name': userName,
      'is_pro': isPro,
      'country': country,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_expired': isExpired,
      'is_bumped': isBumped,
      'images': imageUrls,
      'primary_image': primaryImageUrl,
      'phone_number': phoneNumber,
      'email': email,
    };
  }

  int get daysUntilExpiration {
    return expiresAt.difference(DateTime.now()).inDays;
  }
}

/// Categorías principales del sistema
enum MainCategory {
  servicios('Servicios', ['Plomeros', 'Electricistas', 'Limpieza', 'Reparaciones']),
  transporte('Transporte y Personal', ['Choferes', 'Mensajería', 'Ayudantes', 'Fletes']),
  bienes('Bienes y Activos', ['Autos', 'Inmuebles', 'Muebles', 'Electrónica']),
  empleos('Empleos y Wanted', ['Ofertas de Empleo', 'Busco Trabajo']);

  final String displayName;
  final List<String> subcategories;

  const MainCategory(this.displayName, this.subcategories);
}

/// Modelo para Ubicación Jerárquica
class LocationModel {
  final String country;
  final String state;
  final String city;
  final double? latitude;
  final double? longitude;

  LocationModel({
    required this.country,
    required this.state,
    required this.city,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => '$city, $state, $country';
}

/// Modelo de Usuario
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isPro;
  final DateTime? proExpiresAt;
  final int adsCount;
  final bool isFirstAdFree;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.isPro = false,
    this.proExpiresAt,
    this.adsCount = 0,
    this.isFirstAdFree = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isPro: json['is_pro'] ?? false,
      proExpiresAt: json['pro_expires_at'] != null 
          ? DateTime.parse(json['pro_expires_at']) 
          : null,
      adsCount: json['ads_count'] ?? 0,
      isFirstAdFree: json['first_ad_free'] ?? true,
    );
  }
}
