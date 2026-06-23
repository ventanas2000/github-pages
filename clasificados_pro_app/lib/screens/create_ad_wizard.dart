import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/ad_model.dart';

/// Asistente de 3 pasos para crear anuncios
class CreateAdWizard extends StatefulWidget {
  const CreateAdWizard({super.key});

  @override
  State<CreateAdWizard> createState() => _CreateAdWizardState();
}

class _CreateAdWizardState extends State<CreateAdWizard> {
  int _currentStep = 0;
  
  // Paso 1: Categoría
  MainCategory? _selectedMainCategory;
  String? _selectedSubcategory;
  
  // Paso 2: Detalles
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  List<File> _images = [];
  
  // Paso 3: Ubicación y Contacto
  String? _selectedLocationMode; // 'auto' o 'manual'
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Categoría
        if (_selectedMainCategory == null) {
          _showError('Por favor selecciona una categoría principal');
          return false;
        }
        if (_selectedSubcategory == null) {
          _showError('Por favor selecciona una subcategoría');
          return false;
        }
        break;
      case 1: // Detalles
        if (_titleController.text.trim().isEmpty) {
          _showError('El título es obligatorio');
          return false;
        }
        if (_descriptionController.text.trim().isEmpty) {
          _showError('La descripción es obligatoria');
          return false;
        }
        if (_images.isEmpty) {
          _showError('Debes agregar al menos una foto');
          return false;
        }
        break;
      case 2: // Ubicación y Contacto
        if (_phoneController.text.trim().isEmpty) {
          _showError('El número de teléfono es obligatorio');
          return false;
        }
        if (_selectedLocationMode == 'manual') {
          if (_cityController.text.trim().isEmpty || 
              _stateController.text.trim().isEmpty) {
            _showError('Ciudad y estado son obligatorios en modo manual');
            return false;
          }
        }
        break;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _submitAd() {
    // Aquí iría la lógica para enviar al backend
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    // Simulación de envío
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Cerrar loading
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Anuncio Publicado!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Tu anuncio está ahora visible para miles de personas.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar dialog
                Navigator.pop(context); // Regresar al home
              },
              child: const Text('Ver Anuncios'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicar Anuncio - Paso ${_currentStep + 1}/3'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Column(
        children: [
          // Indicador de progreso
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Contenido del paso actual
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1Category(),
                _buildStep2Details(),
                _buildStep3LocationContact(),
              ],
            ),
          ),
          
          // Botones de navegación
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Atrás'),
              )
            else
              const SizedBox.shrink(),
            
            ElevatedButton(
              onPressed: _currentStep < 2 ? _nextStep : _submitAd,
              child: Text(_currentStep < 2 ? 'Continuar' : 'Publicar Anuncio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PASO 1: CATEGORÍA ====================
  Widget _buildStep1Category() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Paso 1: ¿Qué tipo de anuncio quieres publicar?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona la categoría que mejor describa tu anuncio',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        
        // Categorías principales
        ...MainCategory.values.map((category) => 
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: _selectedMainCategory == category ? 4 : 2,
            color: _selectedMainCategory == category 
                ? Colors.blue[50] 
                : Colors.white,
            child: ExpansionTile(
              leading: Icon(
                _getCategoryIcon(category),
                color: _selectedMainCategory == category 
                    ? Colors.blue 
                    : Colors.grey[700],
                size: 32,
              ),
              title: Text(
                category.displayName,
                style: TextStyle(
                  fontWeight: _selectedMainCategory == category 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: _selectedMainCategory == category 
                      ? Colors.blue 
                      : Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedMainCategory = category;
                  _selectedSubcategory = null;
                });
              },
              children: category.subcategories.map((subcat) => 
                ListTile(
                  title: Text(subcat),
                  selected: _selectedSubcategory == subcat,
                  selectedTileColor: Colors.blue[100],
                  onTap: () {
                    setState(() {
                      _selectedSubcategory = subcat;
                    });
                  },
                ),
              ).toList(),
            ),
          ),
        ).toList(),
      ],
    );
  }

  IconData _getCategoryIcon(MainCategory category) {
    switch (category) {
      case MainCategory.servicios:
        return Icons.build;
      case MainCategory.transporte:
        return Icons.local_shipping;
      case MainCategory.bienes:
        return Icons.home;
      case MainCategory.empleos:
        return Icons.work;
    }
  }

  // ==================== PASO 2: DETALLES ====================
  Widget _buildStep2Details() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Paso 2: Detalles del Anuncio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Agrega información clara y fotos atractivas',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        
        // Título
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Título *',
            hintText: 'Ej: Plomero profesional a domicilio',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(),
          ),
          maxLength: 80,
        ),
        const SizedBox(height: 16),
        
        // Precio
        TextField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: 'Precio (opcional)',
            hintText: '0 si es gratis',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        
        // Descripción
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción *',
            hintText: 'Describe tu producto o servicio en detalle...',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          maxLength: 1000,
        ),
        const SizedBox(height: 24),
        
        // Fotos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotos *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_images.length}/5 fotos',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_images.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para agregar fotos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        if (_images.isNotEmpty && _images.length < 5) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Agregar más fotos'),
          ),
        ],
      ],
    );
  }

  // ==================== PASO 3: UBICACIÓN Y CONTACTO ====================
  Widget _buildStep3LocationContact() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Paso 3: Ubicación y Contacto',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Define dónde estás y cómo contactarte',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        
        // Modo de ubicación
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de Ubicación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Automática (GPS)'),
                    ],
                  ),
                  subtitle: const Text('Usar mi ubicación actual'),
                  value: 'auto',
                  groupValue: _selectedLocationMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationMode = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.location_city, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Manual'),
                    ],
                  ),
                  subtitle: const Text('Seleccionar país, estado y ciudad'),
                  value: 'manual',
                  groupValue: _selectedLocationMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        
        if (_selectedLocationMode == 'manual') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Ciudad *',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'Estado/Provincia *',
              prefixIcon: Icon(Icons.map),
              border: OutlineInputBorder(),
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Contacto
        const Text(
          'Información de Contacto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono/WhatsApp *',
            hintText: '+52 33 1234 5678',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        Text(
          'Este número será visible para los compradores',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        
        const SizedBox(height: 24),
        
        // Resumen
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow('Categoría', '${_selectedMainCategory?.displayName} - $_selectedSubcategory'),
                _buildSummaryRow('Título', _titleController.text),
                _buildSummaryRow('Fotos', '${_images.length} imágenes'),
                _buildSummaryRow('Contacto', _phoneController.text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
