import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../models/taxonomy.dart';
import 'category_selection_screen.dart';
import 'ad_details_screen.dart';
import 'location_contact_screen.dart';

/// Pantalla Principal del Wizard de Creación de Anuncios
/// Controla el flujo de 3 pasos
class CreateAdWizard extends StatefulWidget {
  const CreateAdWizard({Key? key}) : super(key: key);

  @override
  State<CreateAdWizard> createState() => _CreateAdWizardState();
}

class _CreateAdWizardState extends State<CreateAdWizard> {
  int _currentStep = 0;
  
  // Datos temporales del anuncio
  MainCategory? _selectedCategory;
  String? _selectedSubcategory;
  String? _title;
  String? _description;
  double? _price;
  List<dynamic>? _photos;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _restartWizard() {
    setState(() {
      _currentStep = 0;
      _selectedCategory = null;
      _selectedSubcategory = null;
      _title = null;
      _description = null;
      _price = null;
      _photos = null;
    });
  }

  void _submitAd(Map<String, dynamic> adData) {
    // Aquí se enviaría el anuncio al backend
    print('=== ENVIANDO ANUNCIO AL BACKEND ===');
    print('Categoría: ${adData['category']}');
    print('Subcategoría: ${adData['subcategory']}');
    print('Título: ${adData['title']}');
    print('Precio: ${adData['price']}');
    print('Fotos: ${adData['photos'].length}');
    print('Ubicación: ${adData['city']}, ${adData['state']}');
    print('Contacto: ${adData['userName']} - ${adData['userPhone']}');
    
    // Mostrar diálogo de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 40),
            SizedBox(width: 12),
            Text('¡Anuncio Publicado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu anuncio ha sido creado exitosamente.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📁 ${adData['category'].name} > ${adData['subcategory']}'),
                  Text('📝 ${adData['title']}'),
                  Text('💰 \$${adData['price'].toStringAsFixed(2)} USD'),
                  const Divider(),
                  Text('⏰ Tu anuncio expirará en ${(adData['category'] as MainCategory).defaultExpirationDays} días'),
                  Text('🔔 Recibirás una notificación 3 días antes de vencer'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Quieres impulsar tu anuncio?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Con "Bump Ads" puedes destacar tu anuncio por 24 horas y aparecer primero en los resultados.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Regresar a pantalla anterior
            },
            child: const Text('VER MIS ANUNCIOS'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Regresar a pantalla anterior
              // Aquí se podría navegar a la pantalla de pago para Bump Ads
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad Premium: Redirigiendo a pago...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('DESTACAR AHORA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Anuncio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: IndexedStack(
        index: _currentStep,
        children: [
          // Paso 1: Selección de Categoría
          CategorySelectionScreen(
            onCategorySelected: (category, subcategory) {
              setState(() {
                _selectedCategory = category;
                _selectedSubcategory = subcategory;
              });
              _nextStep();
            },
          ),
          
          // Paso 2: Detalles y Fotos
          if (_selectedCategory != null && _selectedSubcategory != null)
            AdDetailsScreen(
              category: _selectedCategory!,
              subcategory: _selectedSubcategory!,
              onDetailsComplete: (title, description, price, photos) {
                setState(() {
                  _title = title;
                  _description = description;
                  _price = price;
                  _photos = photos;
                });
                _nextStep();
              },
            )
          else
            const SizedBox.shrink(),
          
          // Paso 3: Ubicación y Contacto
          if (_selectedCategory != null && _title != null)
            LocationContactScreen(
              category: _selectedCategory!,
              subcategory: _selectedSubcategory!,
              title: _title!,
              description: _description!,
              price: _price!,
              photos: _photos!.cast(),
              onSubmitAd: _submitAd,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
