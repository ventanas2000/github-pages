import 'package:flutter/material.dart';
import '../models/ad_model.dart';

/// Provider principal para manejar el estado de la aplicación
class AppStateProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<AdModel> _ads = [];
  LocationModel? _currentLocation;
  bool _isLoading = false;
  String _searchQuery = '';
  MainCategory? _selectedCategory;
  
  // Modo de ubicación: true = GPS automático, false = Manual jerárquico
  bool _useAutoLocation = true;

  UserModel? get currentUser => _currentUser;
  List<AdModel> get ads => _filteredAds;
  LocationModel? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  MainCategory? get selectedCategory => _selectedCategory;
  bool get useAutoLocation => _useAutoLocation;

  // Filtrado de anuncios basado en búsqueda y categoría
  List<AdModel> get _filteredAds {
    var filtered = _ads;
    
    if (_selectedCategory != null) {
      filtered = filtered.where((ad) => 
        ad.categoryId == _selectedCategory!.name.toLowerCase()
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ad) => 
        ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        ad.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Ordenar: Bumped primero, luego por fecha
    filtered.sort((a, b) {
      if (a.isBumped && !b.isBumped) return -1;
      if (!a.isBumped && b.isBumped) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered;
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void setAds(List<AdModel> ads) {
    _ads = ads;
    notifyListeners();
  }

  void setLocation(LocationModel location, {bool useAuto = true}) {
    _currentLocation = location;
    _useAutoLocation = useAuto;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(MainCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleLocationMode() {
    _useAutoLocation = !_useAutoLocation;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addAd(AdModel ad) {
    _ads.insert(0, ad);
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phoneNumber: _currentUser!.phoneNumber,
        isPro: _currentUser!.isPro,
        proExpiresAt: _currentUser!.proExpiresAt,
        adsCount: _currentUser!.adsCount + 1,
        isFirstAdFree: _currentUser!.adsCount > 0 ? false : _currentUser!.isFirstAdFree,
      );
    }
    notifyListeners();
  }

  // Simulación de carga de datos (en producción esto viene de la API)
  Future<void> loadAds() async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    
    _ads = [
      AdModel(
        id: '1',
        title: 'Plomero Profesional - Reparaciones 24/7',
        description: 'Servicio de plomería a domicilio. Reparación de fugas, instalación de baños, cocinas. Más de 10 años de experiencia.',
        categoryId: 'servicios',
        categoryName: 'Plomeros',
        price: 50,
        userId: 'user1',
        userName: 'Carlos Rodríguez',
        isPro: true,
        country: 'México',
        state: 'Jalisco',
        city: 'Guadalajara',
        latitude: 20.6597,
        longitude: -103.3496,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 58)),
        imageUrls: ['https://via.placeholder.com/400x300?text=Plomero'],
        primaryImageUrl: 'https://via.placeholder.com/400x300?text=Plomero',
        phoneNumber: '+52 33 1234 5678',
      ),
      AdModel(
        id: '2',
        title: 'Toyota Corolla 2020 - Excelente Estado',
        description: 'Vendo Toyota Corolla 2020, único dueño, 45,000 km, todos los servicios en agencia.',
        categoryId: 'bienes',
        categoryName: 'Autos',
        price: 350000,
        userId: 'user2',
        userName: 'María González',
        isPro: false,
        country: 'México',
        state: 'Jalisco',
        city: 'Guadalajara',
        latitude: 20.6700,
        longitude: -103.3500,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 25)),
        isBumped: true,
        imageUrls: ['https://via.placeholder.com/400x300?text=Auto'],
        primaryImageUrl: 'https://via.placeholder.com/400x300?text=Auto',
        phoneNumber: '+52 33 8765 4321',
      ),
      AdModel(
        id: '3',
        title: 'Busco Chofer con Experiencia',
        description: 'Empresa de logística busca chofer con licencia vigente, ruta local. Sueldo base + comisiones.',
        categoryId: 'empleos',
        categoryName: 'Ofertas de Empleo',
        price: 0,
        userId: 'user3',
        userName: 'Logística Express SA',
        isPro: true,
        country: 'México',
        state: 'Jalisco',
        city: 'Zapopan',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 18)),
        imageUrls: [],
        primaryImageUrl: '',
        phoneNumber: '+52 33 1111 2222',
      ),
    ];
    
    setLoading(false);
    notifyListeners();
  }
}
