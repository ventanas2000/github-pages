# Clasificados Pro - Aplicación Móvil

Aplicación móvil de clasificados hiper-local, diseñada para replicar la eficiencia de los periódicos tradicionales como "El Informador" con capacidades móviles modernas.

## 📱 Características Principales

### ✅ Motor de Ubicación Híbrido
- **Modo Automático (GPS)**: Usa la ubicación del dispositivo para mostrar anuncios en un radio específico
- **Modo Manual**: Navegación jerárquica País → Estado → Ciudad

### 📂 Categorización Estricta
4 categorías principales con subcategorías definidas:
- **Servicios**: Plomería, Electricidad, Limpieza, etc.
- **Transporte y Personal**: Conductores, Mensajería, Ayudantes
- **Bienes y Activos**: Autos, Bienes Raíces, Muebles, Electrónica
- **Empleos y Ofertas**: Ofertas de empleo, Busco empleo

### ⏰ Sistema de Expiración Inteligente
- Servicios: 60 días
- Transporte/Personal: 30 días
- Bienes: 20 días (promedio 15-30)
- Empleos: 20 días
- Notificaciones de renovación 3 días antes de vencer

### 🎯 Asistente de 3 Pasos para Publicar
1. **Paso 1**: Selección de Categoría y Subcategoría
2. **Paso 2**: Detalles del anuncio y carga de fotos (hasta 5)
3. **Paso 3**: Ubicación (GPS o manual) y datos de contacto

### 💰 Modelo Freemium
- Primer anuncio GRATIS
- **Bump Ads**: Paga para destacar tu anuncio por X horas
- **Suscripción Pro**: Anuncios ilimitados + insignia "Verificado"

## 🚀 Cómo Ejecutar

### Requisitos Previos
- Flutter SDK 3.0 o superior
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Instalación

```bash
# Navegar al directorio del proyecto
cd clasificados_pro

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Permisos Requeridos

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrar anuncios cercanos</string>
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de tus anuncios</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tu galería para seleccionar fotos</string>
```

## 📁 Estructura del Proyecto

```
clasificados_pro/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── models/
│   │   ├── ad_model.dart            # Modelo de datos de anuncio
│   │   └── taxonomy.dart            # Definición de categorías
│   ├── screens/
│   │   ├── home_screen.dart         # Feed principal con búsqueda
│   │   ├── create_ad_wizard.dart    # Controlador del wizard de 3 pasos
│   │   ├── category_selection_screen.dart  # Paso 1
│   │   ├── ad_details_screen.dart   # Paso 2
│   │   └── location_contact_screen.dart    # Paso 3
│   └── widgets/
│       └── ad_card.dart             # Widget de tarjeta de anuncio
├── pubspec.yaml                     # Dependencias
└── README.md                        # Este archivo
```

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter (Dart)
- **Ubicación**: geolocator
- **Imágenes**: image_picker, cached_network_image
- **UI**: Material Design 3
- **Estado**: setState (para MVP, escalable a Provider/Bloc)

## 📸 Capturas de Pantalla (Descripción)

### Pantalla Principal
- Barra de búsqueda en la parte superior
- Filtros rápidos por categoría (chips horizontales)
- Toggle GPS/Ubicación manual
- Lista de anuncios con tarjetas que muestran:
  - Foto principal
  - Badge "DESTACADO" si es Bump Ad
  - Título, precio, ubicación
  - Tiempo restante para expiración
- Botón flotante "PUBLICAR"

### Wizard de Creación (3 Pasos)
1. **Categorías**: Lista expandible con iconos y subcategorías
2. **Detalles**: Formulario con título, descripción, precio y grid para 5 fotos
3. **Ubicación**: Switch GPS/Manual, dropdowns jerárquicos, resumen final

## 🔮 Próximas Funcionalidades (Roadmap)

- [ ] Autenticación de usuarios (Firebase Auth)
- [ ] Integración con backend (API REST/GraphQL)
- [ ] Pasarela de pagos para Bump Ads y Suscripciones
- [ ] Chat entre comprador y vendedor
- [ ] Sistema de calificaciones y reseñas
- [ ] Notificaciones push para renovaciones
- [ ] Modo oscuro
- [ ] Soporte multi-idioma

## 📄 Licencia

Proyecto desarrollado como blueprint técnico para "Clasificados Pro".

---

**Desarrollado con ❤️ usando Flutter**
