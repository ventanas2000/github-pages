import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../widgets/ad_card.dart';
import 'create_ad_wizard.dart';

/// Pantalla Principal (Home) con Feed de Anuncios
/// Soporta búsqueda híbrida: por GPS (radio) o por ubicación manual (Ciudad/Estado)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtros de búsqueda
  bool _useGPSLocation = false;
  String? _selectedCategory;
  String _searchQuery = '';
  
  // Datos simulados (en producción vendrían de la API)
  final List<AdModel> _ads = [
    AdModel(
      id: '1',
      title: 'Plomero Experto - Reparaciones 24/7',
      description: 'Servicio profesional de plomería...',
      category: 'Servicios',
      subcategory: 'Plomería',
      price: 350,
      userId: 'user1',
      userName: 'Juan Pérez',
      userPhone: '+52 33 1234 5678',
      country: 'México',
      state: 'Jalisco',
      city: 'Guadalajara',
      latitude: 20.6597,
      longitude: -103.3496,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 58)),
      isBumped: true,
      imageUrls: ['https://via.placeholder.com/400x300?text=Plomero'],
    ),
    AdModel(
      id: '2',
      title: 'Vendo Toyota Corolla 2020',
      description: 'Excelente estado, único dueño...',
      category: 'Bienes y Activos',
      subcategory: 'Automóviles',
      price: 350000,
      userId: 'user2',
      userName: 'María González',
      userPhone: '+52 33 8765 4321',
      country: 'México',
      state: 'Jalisco',
      city: 'Zapopan',
      latitude: 20.7214,
      longitude: -103.3918,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 18)),
      isBumped: false,
      imageUrls: ['https://via.placeholder.com/400x300?text=Corolla'],
    ),
    AdModel(
      id: '3',
      title: 'Busco Empleo como Conductor',
      description: 'Licencia vigente, experiencia 5 años...',
      category: 'Empleos y Ofertas',
      subcategory: 'Busco Empleo',
      price: 0,
      userId: 'user3',
      userName: 'Carlos Ramírez',
      userPhone: '+52 33 5555 6666',
      country: 'México',
      state: 'Jalisco',
      city: 'Guadalajara',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 2)), // Próximo a vencer
      isBumped: false,
      imageUrls: [],
    ),
    AdModel(
      id: '4',
      title: 'Electricista Residencial y Comercial',
      description: 'Instalaciones, reparaciones, mantenimiento...',
      category: 'Servicios',
      subcategory: 'Electricidad',
      price: 400,
      userId: 'user4',
      userName: 'ElectroServicios SA',
      userPhone: '+52 33 7777 8888',
      country: 'México',
      state: 'Jalisco',
      city: 'Tlaquepaque',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 55)),
      isBumped: false,
      imageUrls: ['https://via.placeholder.com/400x300?text=Electricista'],
    ),
  ];

  List<AdModel> get _filteredAds {
    var filtered = _ads;
    
    // Filtrar por categoría
    if (_selectedCategory != null) {
      filtered = filtered.where((ad) => ad.category == _selectedCategory).toList();
    }
    
    // Filtrar por búsqueda de texto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ad) => 
        ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        ad.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Ordenar: Bump Ads primero, luego por fecha
    filtered.sort((a, b) {
      if (a.isBumped && !b.isBumped) return -1;
      if (!a.isBumped && b.isBumped) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificados Pro'),
        actions: [
          IconButton(
            icon: Icon(_useGPSLocation ? Icons.gps_fixed : Icons.gps_off),
            tooltip: _useGPSLocation ? 'Usando GPS' : 'Ubicación manual',
            onPressed: () {
              setState(() {
                _useGPSLocation = !_useGPSLocation;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_useGPSLocation 
                    ? 'Mostrando anuncios cerca de ti (GPS)' 
                    : 'Mostrando anuncios por ciudad'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Buscador
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar anuncios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filtro por categoría
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...['Servicios', 'Bienes y Activos', 'Empleos y Ofertas', 'Transporte']
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = selected ? category : null;
                                    });
                                  },
                                ),
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de anuncios
          Expanded(
            child: _filteredAds.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron anuncios',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredAds.length,
                    itemBuilder: (context, index) {
                      final ad = _filteredAds[index];
                      return AdCard(
                        ad: ad,
                        onTap: () {
                          // Navegar al detalle del anuncio
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viendo: ${ad.title}')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // Botón flotante para crear anuncio
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAdWizard()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('PUBLICAR'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
