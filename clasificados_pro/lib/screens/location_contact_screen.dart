import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/taxonomy.dart';

/// Pantalla 3 del Wizard: Ubicación y Contacto
class LocationContactScreen extends StatefulWidget {
  final MainCategory category;
  final String subcategory;
  final String title;
  final String description;
  final double price;
  final List<File> photos;
  final Function(Map<String, dynamic> adData) onSubmitAd;

  const LocationContactScreen({
    Key? key,
    required this.category,
    required this.subcategory,
    required this.title,
    required this.description,
    required this.price,
    required this.photos,
    required this.onSubmitAd,
  }) : super(key: key);

  @override
  State<LocationContactScreen> createState() => _LocationContactScreenState();
}

class _LocationContactScreenState extends State<LocationContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Ubicación manual
  String _selectedCountry = 'México';
  String? _selectedState;
  String? _selectedCity;
  
  // Ubicación automática (GPS)
  bool _useAutomaticLocation = false;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  // Datos simulados para estados y ciudades (en producción vendrían de la API)
  final Map<String, List<String>> _statesByCountry = {
    'México': ['Jalisco', 'Ciudad de México', 'Nuevo León', 'Yucatán'],
  };
  
  final Map<String, List<String>> _citiesByState = {
    'Jalisco': ['Guadalajara', 'Zapopan', 'Tlaquepaque', 'Puerto Vallarta'],
    'Ciudad de México': ['Centro', 'Polanco', 'Coyoacán', 'Xochimilco'],
    'Nuevo León': ['Monterrey', 'San Pedro', 'Apodaca'],
    'Yucatán': ['Mérida', 'Progreso', 'Valladolid'],
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Usuario Demo'; // En producción, obtener del perfil logueado
    _phoneController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _useAutomaticLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los servicios de ubicación están deshabilitados')),
        );
        setState(() {
          _isGettingLocation = false;
          _useAutomaticLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
          setState(() {
            _isGettingLocation = false;
            _useAutomaticLocation = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación obtenida exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $e')),
      );
      setState(() {
        _isGettingLocation = false;
        _useAutomaticLocation = false;
      });
    }
  }

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      if (!_useAutomaticLocation && (_selectedState == null || _selectedCity == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar estado y ciudad')),
        );
        return;
      }

      final adData = {
        'category': widget.category,
        'subcategory': widget.subcategory,
        'title': widget.title,
        'description': widget.description,
        'price': widget.price,
        'photos': widget.photos,
        'userName': _nameController.text.trim(),
        'userPhone': _phoneController.text.trim(),
        'country': _selectedCountry,
        'state': _selectedState,
        'city': _selectedCity,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'useAutomaticLocation': _useAutomaticLocation,
      };

      widget.onSubmitAd(adData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Anuncio - Paso 3'),
        subtitle: const Text('Ubicación y contacto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selector de modo de ubicación
            Card(
              child: SwitchListTile(
                title: const Text('Usar mi ubicación actual (GPS)'),
                subtitle: const Text('Recomendado para mayor precisión'),
                subtitleStyle: TextStyle(color: Colors.blue.shade700),
                value: _useAutomaticLocation,
                onChanged: (value) {
                  setState(() {
                    _useAutomaticLocation = value;
                    if (value) {
                      _getCurrentLocation();
                    }
                  });
                },
                secondary: Icon(
                  _useAutomaticLocation ? Icons.gps_fixed : Icons.gps_off,
                  color: _useAutomaticLocation ? Colors.green : Colors.grey,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ubicación Manual (solo si no usa GPS)
            if (!_useAutomaticLocation) ...[
              // País
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                ),
                items: _statesByCountry.keys.map((country) {
                  return DropdownMenuItem(value: country, child: Text(country));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                    _selectedState = null;
                    _selectedCity = null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Estado
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                hint: const Text('Selecciona un estado'),
                items: _statesByCountry[_selectedCountry]!.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Ciudad
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                hint: const Text('Selecciona una ciudad'),
                items: (_selectedState != null ? _citiesByState[_selectedState] ?? [] : [])
                    .map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
            ] else ...[
              // Vista de ubicación GPS
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isGettingLocation
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Obteniendo ubicación...'),
                          ],
                        )
                      : _currentPosition != null
                          ? Column(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  'Ubicación detectada',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          : const Text('Presiona el botón para obtener tu ubicación'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Datos de Contacto
            const Text(
              'Datos de Contacto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cómo te contactarán los interesados',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 16),
            
            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Empresa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono / WhatsApp',
                hintText: '+52 33 1234 5678',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es obligatorio';
                }
                if (value.length < 10) {
                  return 'Ingresa un teléfono válido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Resumen del anuncio
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Anuncio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('📁 ${widget.category.name} > ${widget.subcategory}'),
                    Text('📝 ${widget.title}'),
                    Text('💰 \$${widget.price.toStringAsFixed(2)} USD'),
                    Text('📸 ${widget.photos.length} foto(s)'),
                    const SizedBox(height: 8),
                    Text(
                      _useAutomaticLocation 
                          ? '📍 Ubicación: Automática (GPS)' 
                          : '📍 Ubicación: ${_selectedCity ?? ''}, ${_selectedState ?? ''}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón Publicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGettingLocation ? null : _submitAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'PUBLICAR ANUNCIO',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Tu primer anuncio es GRATIS. Se publicará inmediatamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
