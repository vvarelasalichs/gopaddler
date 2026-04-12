# GoPaddler Flutter Migration - Project Structure

Este es el nuevo proyecto GoPaddler migrado a **Flutter**.

## 📁 Estructura del Proyecto

```
gopaddler_flutter/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── config/
│   │   ├── app_config.dart       # App configuration & endpoints
│   │   ├── routes.dart           # GoRouter configuration
│   │   └── theme.dart            # Material themes (light/dark)
│   ├── data/
│   │   ├── datasources/          # Local & remote data sources
│   │   │   ├── local/            # SQLite operations
│   │   │   └── remote/           # API & WebSocket clients
│   │   ├── models/               # Data models
│   │   └── repositories/         # Repository pattern implementation
│   ├── domain/                   # Domain layer (clean architecture)
│   │   ├── entities/             # Business entities
│   │   ├── repositories/         # Repository interfaces
│   │   └── usecases/             # Business logic
│   ├── presentation/             # UI layer
│   │   ├── bloc/                 # BLoC state management
│   │   ├── pages/                # Full page screens
│   │   └── widgets/              # Reusable widgets
│   ├── services/                 # Core services
│   │   ├── gps_service.dart
│   │   ├── ble_service.dart
│   │   ├── sensor_service.dart
│   │   ├── database_service.dart
│   │   └── sync_service.dart
│   ├── utils/                    # Utility functions
│   └── di/                       # Dependency injection
├── test/                         # Unit & widget tests
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## 🚀 Instalación y Setup

### Requisitos Previos
- **Flutter SDK** (>=3.0.0) - [Descargar](https://flutter.dev/docs/get-started/install)
- **Android SDK** (API level 21+)
- **Xcode** (para iOS)
- **VS Code** o **Android Studio**

### Instalación de Flutter

1. Descargar y extraer Flutter SDK
2. Agregar al PATH:
   ```bash
   export PATH="$PATH:$(pwd)/flutter/bin"
   ```
3. Verificar instalación:
   ```bash
   flutter doctor
   ```

### Setup Inicial del Proyecto

```bash
cd gopaddler_flutter

# Obtener dependencias
flutter pub get

# Generar código (JSON serialization, etc.)
flutter pub run build_runner build

# Ejecutar en emulador/dispositivo
flutter run
```

## 📦 Dependencias Principales

| Dependencia | Propósito |
|-------------|-----------|
| `flutter_bloc` | State Management |
| `geolocator` | GPS Tracking |
| `flutter_blue_plus` | Bluetooth BLE |
| `sqflite` | SQLite Database |
| `web_socket_channel` | Real-time Sync |
| `fl_chart` | Data Visualization |
| `intl` | Localization |

Ver `pubspec.yaml` para lista completa.

## 🏗️ Arquitectura

El proyecto utiliza **Clean Architecture** con tres capas:

### 1. **Data Layer**
- Gestiona acceso a datos (SQLite, APIs)
- Implementa Repository pattern
- Manejo de caché local

### 2. **Domain Layer**
- Lógica de negocio pura
- Independiente de frameworks
- Entidades y use cases

### 3. **Presentation Layer**
- UI con Flutter
- State management con BLoC
- Widgets reutilizables

## 📱 Pantallas Implementadas

- [ ] **Home** - Pantalla principal (50% implementado)
- [ ] **Sessions** - Listado de sesiones (stub)
- [ ] **Session Active** - Grabación en tiempo real (stub)
- [ ] **Session Summary** - Resumen post-sesión (stub)
- [ ] **Settings** - Configuración (stub)
- [ ] **Bluetooth** - Gestión de dispositivos BLE (stub)
- [ ] **Calibration** - Calibración de sensores (stub)

## 🔌 Integraciones

### GPS & Sensores
- `geolocator` - Background GPS
- `sensors_plus` - Acelerómetro/Giroscopio
- `flutter_blue_plus` - Bluetooth BLE

### Base de Datos
- `sqflite` - SQLite para sesiones locales
- Migraciones automáticas

### Sincronización
- WebSocket para real-time sync
- Soporte offline-first
- Sincronización automática al reconectar

## 🧪 Testing

```bash
# Unit tests
flutter test

# Tests específicos
flutter test test/services/gps_service_test.dart

# Coverage
flutter test --coverage
```

## 🏃 Desarrollo

### Hot Reload
```bash
flutter run
# Presionar 'r' para hot reload
# Presionar 'R' para hot restart
```

### Debug Logging
```bash
flutter run -v  # Modo verbose
```

### Análisis de código
```bash
flutter analyze
dart format lib/
```

## 📊 Monitoreo de Performance

```bash
flutter run --profile
flutter run --release
```

## 🔧 Customización

### Cambiar Endpoint
En `config/app_config.dart`:
```dart
EnvironmentConfig.currentEnvironment = Environment.prod;
```

### Agregar Idioma
1. Agregar a `AppConfig.supportedLanguages`
2. Crear archivos de localización en `assets/translations/`

## ⚠️ Notas Importantes

1. **Schema SQL**: Mantiene compatibilidad con proyecto Cordova original
2. **Versión**: App v1.8.0 (migración de v1.7.3)
3. **Soporte de plataformas**: Android y iOS
4. **Min SDK**: Android 21, iOS 11+

## 📚 Recursos

- [Flutter Docs](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Sqflite](https://pub.dev/packages/sqflite)

## 🐛 Troubleshooting

### "flutter: command not found"
```bash
# Agregar Flutter al PATH
export PATH="$PATH:$HOME/flutter/bin"
```

### Issues con dependencias
```bash
flutter clean
flutter pub get
```

### Android build issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

## ✅ Checklist de Desarrollo

- [ ] Routing funcionando correctamente
- [ ] Database migrations completadas
- [ ] GPS tracking en tiempo real
- [ ] Bluetooth BLE conectando sensors
- [ ] WebSocket sync funcionando
- [ ] UI principal implementada
- [ ] Settings/Configuración OK
- [ ] Tests pasando
- [ ] Release build funcional

## 📝 Notas de Migración

Este proyecto es parte de la **FASE 1** del plan de migración completo.

Ver `../MIGRATION_PLAN.md` para detalles del plan total.

---

**Última actualización:** 12 de Abril 2026
