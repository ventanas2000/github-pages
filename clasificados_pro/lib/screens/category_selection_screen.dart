import 'package:flutter/material.dart';
import '../models/taxonomy.dart';

/// Pantalla 1 del Wizard: Selección de Categoría
class CategorySelectionScreen extends StatefulWidget {
  final Function(MainCategory, String) onCategorySelected;

  const CategorySelectionScreen({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  MainCategory? _selectedMainCategory;
  String? _selectedSubcategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Anuncio - Paso 1'),
        subtitle: const Text('Selecciona una categoría'),
      ),
      body: Column(
        children: [
          // Selector de Categoría Principal
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MainCategory.values.length,
              itemBuilder: (context, index) {
                final category = MainCategory.values[index];
                final isSelected = _selectedMainCategory == category;
                
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(category),
                      color: isSelected ? Colors.blue : Colors.grey,
                      size: 32,
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('${Taxonomy.getSubcategories(category).length} subcategorías'),
                    onTap: () {
                      setState(() {
                        _selectedMainCategory = category;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Selector de Subcategoría (solo si hay categoría principal seleccionada)
          if (_selectedMainCategory != null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Selecciona la subcategoría:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Taxonomy.getSubcategories(_selectedMainCategory!).length,
                      itemBuilder: (context, index) {
                        final subcategory = Taxonomy.getSubcategories(_selectedMainCategory!)[index];
                        final isSelected = _selectedSubcategory == subcategory;
                        
                        return ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? Colors.green : Colors.grey,
                          ),
                          title: Text(subcategory),
                          onTap: () {
                            setState(() {
                              _selectedSubcategory = subcategory;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Botón Continuar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedMainCategory != null && _selectedSubcategory != null)
                    ? () => widget.onCategorySelected(_selectedMainCategory!, _selectedSubcategory!)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(MainCategory category) {
    switch (category) {
      case MainCategory.servicios: return Icons.build;
      case MainCategory.transportePersonal: return Icons.local_shipping;
      case MainCategory.bienesActivos: return Icons.store;
      case MainCategory.empleosOfertas: return Icons.work;
    }
  }
}
