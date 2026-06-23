# Clasificados Pro - Aplicación Móvil

Aplicación móvil multiplataforma (iOS/Android) para el marketplace hiperlocal "Clasificados Pro".

## 🚀 Características Principales

### ✅ Implementadas
- **Motor de Ubicación Híbrido**: Soporte para GPS automático y selección manual (País → Estado → Ciudad)
- **Categorización Estricta**: 4 categorías principales con subcategorías
  - Servicios (Plomeros, Electricistas, Limpieza, Reparaciones)
  - Transporte y Personal (Choferes, Mensajería, Ayudantes, Fletes)
  - Bienes y Activos (Autos, Inmuebles, Muebles, Electrónica)
  - Empleos y Wanted (Ofertas de Empleo, Busco Trabajo)
- **Asistente de 3 Pasos**: Flujo simplificado para crear anuncios
  - Paso 1: Selección de Categoría
  - Paso 2: Detalles y Fotos
  - Paso 3: Ubicación y Contacto
- **Feed Inteligente**: Anuncios ordenados por relevancia (Bumped primero, luego fecha)
- **Búsqueda y Filtrado**: Por categoría, texto y ubicación
- **Perfil de Usuario**: Estadísticas, estado PRO, anuncios activos

## 📁 Estructura del Proyecto

```
clasificados_pro_app/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── models/
│   │   └── ad_model.dart            # Modelos de datos
│   ├── providers/
│   │   └── app_state_provider.dart  # Gestión de estado
│   ├── screens/
│   │   ├── home_screen.dart         # Pantalla principal
│   │   ├── ad_detail_screen.dart    # Detalle de anuncio
│   │   └── create_ad_wizard.dart    # Asistente de creación
│   └── widgets/                     # Componentes reutilizables
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml                     # Dependencias
└── README.md
```

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework multiplataforma
- **Provider**: Gestión de estado
- **Image Picker**: Selección de imágenes
- **Geolocator**: Ubicación GPS
- **Material Design 3**: UI moderna

## 🏃 Ejecución

### Requisitos Previos
- Flutter SDK 3.0+
- Android Studio / VS Code
- Emulador o dispositivo físico

### Instalación

```bash
# Navegar al directorio del proyecto
cd clasificados_pro_app

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Construir para producción
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📱 Capturas de Pantalla

La aplicación incluye:
- Feed principal con tarjetas de anuncios
- Detalle completo con galería de imágenes
- Asistente paso a paso con validación
- Selector de modo de ubicación (GPS/Manual)
- Perfil de usuario con estadísticas

## 🔐 Próximas Implementaciones

- [ ] Autenticación de usuarios (Firebase Auth)
- [ ] Integración con backend API
- [ ] Subida de imágenes a CDN
- [ ] Notificaciones push para renovación
- [ ] Pagos para anuncios destacados
- [ ] Chat entre usuarios
- [ ] Sistema de calificaciones

## 📄 Licencia

Propiedad de Clasificados Pro - Todos los derechos reservados.
