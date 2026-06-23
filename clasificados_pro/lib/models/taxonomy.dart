/// Definición de Taxonomía y Categorías
/// Estructura estricta: Categoría -> Subcategorías

enum MainCategory {
  servicios,
  transportePersonal,
  bienesActivos,
  empleosOfertas,
}

extension MainCategoryExtension on MainCategory {
  String get name {
    switch (this) {
      case MainCategory.servicios: return 'Servicios';
      case MainCategory.transportePersonal: return 'Transporte y Personal';
      case MainCategory.bienesActivos: return 'Bienes y Activos';
      case MainCategory.empleosOfertas: return 'Empleos y Ofertas';
    }
  }

  int get defaultExpirationDays {
    switch (this) {
      case MainCategory.servicios: return 60;
      case MainCategory.transportePersonal: return 30;
      case MainCategory.bienesActivos: return 20; // Promedio entre 15-30
      case MainCategory.empleosOfertas: return 20;
    }
  }
}

class CategoryData {
  final MainCategory main;
  final String subcategory;
  
  const CategoryData({required this.main, required this.subcategory});
}

/// Mapa completo de categorías y subcategorías
class Taxonomy {
  static final Map<MainCategory, List<String>> _data = {
    MainCategory.servicios: [
      'Plomería',
      'Electricidad',
      'Limpieza',
      'Carpintería',
      'Pintura',
      'Jardinería',
      'Reparación de Electrodomésticos',
      'Clases Particulares',
      'Cuidado de Mascotas',
      'Otros Servicios',
    ],
    MainCategory.transportePersonal: [
      'Conductores',
      'Mensajería y Paquetería',
      'Ayudantes Generales',
      'Cargadores',
      'Choferes Particulares',
      'Transporte de Carga',
    ],
    MainCategory.bienesActivos: [
      'Automóviles',
      'Motocicletas',
      'Bienes Raíces (Venta)',
      'Bienes Raíces (Renta)',
      'Muebles',
      'Electrónica',
      'Herramientas',
      'Ropa y Accesorios',
    ],
    MainCategory.empleosOfertas: [
      'Ofertas de Empleo',
      'Busco Empleo',
      'Trabajos Temporales',
      'Prácticas y Pasantías',
    ],
  };

  /// Obtiene todas las subcategorías de una categoría principal
  static List<String> getSubcategories(MainCategory category) {
    return _data[category] ?? [];
  }

  /// Obtiene todas las categorías principales
  static List<MainCategory> getAllCategories() {
    return MainCategory.values;
  }
  
  /// Valida si una subcategoría existe para una categoría dada
  static bool isValidSubcategory(MainCategory category, String subcategory) {
    return _data[category]?.contains(subcategory) ?? false;
  }
}
