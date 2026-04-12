# GoPaddler Migration Plan - Análisis y Estrategia

**Fecha de inicio:** 12 de abril de 2026  
**Estado actual:** Análisis completado ✅  
**Siguiente paso:** Crear branch y estructura del nuevo proyecto

---

## 1. ANÁLISIS DEL PROYECTO ACTUAL

### Stack Tecnológico Actual
- **Framework Base:** Apache Cordova v11.0.0
- **Lenguaje:** JavaScript ES6+
- **Build Tool:** Webpack
- **Plantillas:** Art-template
- **CSS:** Personalizado sin framework (SCSS/CSS puro)
- **Base de datos:** SQLite (cordova-sqlite-storage)
- **Sincronización:** WebSocket (Asteroid.js)
- **Versión Node:** 0.10.21 (OBSOLETA - ~2014)

### Features Principales Identificados

#### 1. **Tracking de Actividades (Paddle/Cycling)**
- GPS tracking en tiempo real
- Detección automática de strokes
- Medición de distancia, velocidad, ritmo
- Sensor de acelerómetro (cordova-plugin-device-motion)
- Cálculo de eficiencia

#### 2. **Conectividad Bluetooth**
- **Sensores BLE:**
  - Heart Rate Monitor (HR)
  - Cycling Cadence Sensor
- Sincronización automática de dispositivos BLE
- Reconexión inteligente con retry exponencial
- Ubicación requerida en Android

#### 3. **Geolocalización**
- Background geolocation (background-geolocation-lt)
- GPS activo durante sesiones
- Rate configurable (configurable en settings)

#### 4. **Audio & Notificaciones**
- Soundboard de audio nativo (cordova-plugin-nativeaudio)
- Vibración (cordova-plugin-vibration)
- Control de modo "no molestar" (cordova-plugin-powermanagement)

#### 5. **Análisis de Datos**
- Gráficos interactivos (Chart.js + plugin datalabels)
- Resumen de sesiones con métricas
- Splits/Intervalos
- Zonas de entrenamiento
- Integración Strava

#### 6. **Integraciones Externas**
- Sincronización con servidor (WebSocket)
- Integración Strava
- Deep linking (cordova-plugin-deeplinks)
- InApp browser

#### 7. **Configuración**
- Selección de idioma
- Calibración de sensores
- Selección de bote/tipo de actividad
- Settings de usuario
- Perfiles de coach

### Pantallas Identificadas

| Pantalla | Descripción |
|----------|-------------|
| **Home** | Pantalla principal |
| **Sessions** | Listado de sesiones grabadas |
| **Session (Active)** | Grabación activa con métricas en tiempo real |
| **Session Summary** | Resumen post-sesión con gráficos y análisis |
| **Select Session** | Selector de sesión previa |
| **Settings** | Configuración general |
| **Calibration** | Calibración de sensores |
| **Calibration Help** | Ayuda de calibración |
| **GPS Update Rate** | Configurar frecuencia GPS |
| **Heart Rate Setup** | Configurar monitor de frecuencia cardíaca |
| **Choose Boat** | Selector de tipo de embarcación |
| **Bluetooth Devices** | Gestión de apareos BLE |
| **Language** | Selector de idioma |
| **Coach Management** | Gestión de perfiles de coach |
| **Choose Sport** | Selector de deporte (paddling/cycling) |
| **Profile** | Perfil de usuario |
| **Strava Redirect** | Autenticación Strava |

### Base de Datos
- **Motor:** SQLite
- **Tabla principal:** sessions (con detalles, splits, zonas)
- **Localización:** `sessions.db`

### Plugins Críticos a Migrar
```
1. Geolocalización: @mauron85/cordova-plugin-background-geolocation
2. Bluetooth: cordova-plugin-bluetoothle
3. Motion: cordova-plugin-device-motion (acelerómetro)
4. Audio: cordova-plugin-nativeaudio
5. Notificaciones: cordova-plugin-dialogs, vibration
6. Storage: cordova-sqlite-storage
7. Network: cordova-plugin-network-information
```

---

## 2. ANÁLISIS DE ALTERNATIVAS DE MIGRACIÓN

### Opción A: Flutter (RECOMENDADA ✅)
**Puntuación: 9/10**

#### Ventajas
✅ Código único para iOS y Android  
✅ Performance nativo excepcional  
✅ Hot reload durante desarrollo  
✅ Excelente soporte para Bluetooth BLE  
✅ Plugins maduros para geolocalización y sensores  
✅ Mayor velocidad de desarrollo  
✅ Comunidad muy activa  
✅ Mejor experiencia de usuario  
✅ Mantenimiento a largo plazo  

#### Desventajas
❌ Necesario aprender Dart  
❌ Tamaño del APK inicial puede ser mayor (~40MB)  
❌ Menos Stack Overflow answers vs React Native

#### Plugins Disponibles
- `geolocator` - Geolocalización con background support
- `flutter_blue_plus` - Bluetooth BLE
- `sensors_plus` - Acelerómetro/Giroscopio
- `just_audio` - Audio
- `sqflite` - SQLite
- `web_socket_channel` - WebSocket

---

### Opción B: React Native
**Puntuación: 7.5/10**

#### Ventajas
✅ Código JavaScript (menor curva aprendizaje)  
✅ Comunidad muy grande  
✅ Muchos componentes third-party  
✅ Desarrollo rápido inicial  

#### Desventajas
❌ Performance inferior a Flutter para este tipo de app  
❌ Bluetooth BLE requiere librerías complejas  
❌ Geolocalización en background más complicada  
❌ Mantenimiento de dependencias más complejo  
❌ Tamaño de APK similar o mayor  

---

### Opción C: Capacitor (Hybrid - No recomendado)
**Puntuación: 5/10**

#### Ventajas
✅ Reutilizable mucho código actual  
✅ Misma arquitectura que Cordova  
✅ Fácil migración inicial  

#### Desventajas
❌ Mantiene limitaciones de Cordova  
❌ Performance subóptimo para tracking en tiempo real  
❌ No resuelve problemas fundamentales de Cordova  
❌ Bluetooth BLE aún problemático  

---

### Opción D: Kotlin Nativo (Android-only)
**Puntuación: 6/10**

#### Ventajas
✅ Maximum performance  
✅ Acceso nativo completo a APIs Android  
✅ Material Design nativo  

#### Desventajas
❌ Solo Android (perder iOS)  
❌ Mantenimiento duplicado de código  
❌ Mayor costo de desarrollo  
❌ Peor experiencia de usuario en iOS  

---

## 3. DECISIÓN: FLUTTER ✅

### Por qué Flutter es la mejor opción

1. **Performance real-time**
   - Tracking GPS y Bluetooth requieren precisión
   - Flutter maneja bien múltiples sensores simultáneos
   - Mejor GC que React Native

2. **Soporte Bluetooth BLE superior**
   - `flutter_blue_plus` es muy maduro
   - Menor latencia
   - Mejor manejo de errores de conexión

3. **Background execution**
   - `workmanager` para background tasks
   - Mejor control de ciclo de vida

4. **Gráficos y UI**
   - `fl_chart` superior para este caso de uso
   - Mejor rendimiento que web-based charts
   - Más opciones de animación

5. **Base de datos**
   - `sqflite` con soporte completo de migraciones
   - Fácil transición desde SQLite actual

6. **Escalabilidad futura**
   - Community de Flutter en crecimiento
   - Google commitment a largo plazo
   - Mejor para mantenimiento futuro

---

## 4. PLAN DE MIGRACIÓN - FASES

### FASE 1: Preparación (1 día)
- [ ] Crear branch `migration/flutter`
- [ ] Inicializar proyecto Flutter
- [ ] Configurar estructura de carpetas
- [ ] Setup de dependencias base

### FASE 2: Arquitectura Base (2 días)
- [ ] Implementar routing/navegación
- [ ] Setup de state management (Provider)
- [ ] Estructura de carpetas escalable
- [ ] Configuración de entornos (dev/prod)

### FASE 3: Base de Datos (1 día)
- [ ] Migración de schema SQLite a Dart
- [ ] Setup sqflite
- [ ] Modelos Dart con serialización
- [ ] Repositorio de persistencia

### FASE 4: Core Features - Tracking (2 días)
- [ ] Geolocalización setup
- [ ] GPS tracking en tiempo real
- [ ] Detector de strokes migrado
- [ ] Pantalla de sesión activa

### FASE 5: Bluetooth & Sensores (2 días)
- [ ] Setup flutter_blue_plus
- [ ] BLE Manager migrado
- [ ] Heart Rate sync
- [ ] Acelerómetro integration

### FASE 6: Sincronización & WebSocket (1 día)
- [ ] Conexión WebSocket
- [ ] Sincronización con servidor
- [ ] Manejo de offline

### FASE 7: UI - Pantallas Principales (3 días)
- [ ] Home screen
- [ ] Sessions list
- [ ] Session active (tracking)
- [ ] Session summary

### FASE 8: UI - Configuración (2 días)
- [ ] Settings screen
- [ ] Calibration screens
- [ ] Language selector
- [ ] Profile management

### FASE 9: Features Avanzadas (2 días)
- [ ] Gráficos y analytics
- [ ] Integración Strava
- [ ] Notificaciones
- [ ] Audio feedback

### FASE 10: Testing & QA (2 días)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Testing en device real
- [ ] Performance optimization

### FASE 11: Release Prep (1 día)
- [ ] Build release APK/IPA
- [ ] Documentación
- [ ] Setup de CI/CD

**Tiempo total estimado: 19 días**

---

## 5. DEPENDENCIAS FLUTTER A INSTALAR

### Críticas
```yaml
flutter_bloc: ^8.1.0          # Estado
provider: ^6.0.0              # Inyección de dependencias
get_it: ^7.0.0                # Service locator
```

### Geolocalización & Sensores
```yaml
geolocator: ^9.0.0            # GPS
flutter_blue_plus: ^1.30.0    # Bluetooth
sensors_plus: ^2.0.0          # Acelerómetro
workmanager: ^0.5.0           # Background jobs
```

### Base de Datos
```yaml
sqflite: ^2.3.0               # SQLite
path_provider: ^2.1.0         # App directories
```

### Networking & Sync
```yaml
web_socket_channel: ^2.4.0    # WebSocket
http: ^1.1.0                  # HTTP requests
```

### UI & Gráficos
```yaml
fl_chart: ^0.64.0             # Gráficos
curved_navigation_bar: ^1.0.0 # Navegación
```

### Utilidades
```yaml
intl: ^0.19.0                 # Localización
just_audio: ^0.9.0            # Audio
vibration: ^1.8.0             # Vibración
```

---

## 6. ESTRUCTURA PROPUESTA DEL PROYECTO

```
gopaddler-flutter/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── session_local_datasource.dart
│   │   │   │   └── settings_local_datasource.dart
│   │   │   └── remote/
│   │   │       ├── api_client.dart
│   │   │       └── websocket_client.dart
│   │   ├── models/
│   │   │   ├── session.dart
│   │   │   ├── device.dart
│   │   │   ├── settings.dart
│   │   │   └── measurement.dart
│   │   └── repositories/
│   │       ├── session_repository.dart
│   │       ├── device_repository.dart
│   │       └── settings_repository.dart
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── session_bloc/
│   │   │   ├── ble_bloc/
│   │   │   ├── gps_bloc/
│   │   │   └── settings_bloc/
│   │   ├── pages/
│   │   │   ├── home_page.dart
│   │   │   ├── sessions_page.dart
│   │   │   ├── session_active_page.dart
│   │   │   ├── session_summary_page.dart
│   │   │   ├── settings_page.dart
│   │   │   └── ...
│   │   └── widgets/
│   │       ├── bluetooth_device_tile.dart
│   │       ├── metric_card.dart
│   │       ├── gps_indicator.dart
│   │       └── ...
│   ├── services/
│   │   ├── gps_service.dart
│   │   ├── ble_service.dart
│   │   ├── sensor_service.dart
│   │   ├── database_service.dart
│   │   └── sync_service.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── extensions.dart
│   │   ├── logger.dart
│   │   └── formatters.dart
│   └── di/
│       └── service_locator.dart
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 7. DATOS A MIGRAR

### De código JavaScript a Dart
1. **Detección de strokes** → `services/stroke_detector.dart`
2. **Cálculos de métrica** → `models/measurements.dart`
3. **Lógica BLE** → `services/ble_service.dart`
4. **Sincronización** → `services/sync_service.dart`

### De SQLite a SQLite (migration via sqflite)
- Schema se mantiene pero modelos se adaptan
- Migraciones Dart

### APIs y Endpoints
- Mantener iguales (dev, remote-dev, prod)

---

## 8. RIESGOS Y MITIGACIÓN

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|-----------|
| Curva aprendizaje Dart | Alta | Training videos, Sprint inicial documentación |
| Performance BLE diferente | Media | Testing exhaustivo en devices reales |
| Cambios en API servidor | Media | Versioning continuo |
| Migración schema DB compleja | Media | Generador de migraciones |
| Compatibilidad BLE Android | Media | Testing con múltiples dispositivos |
| Tamaño APK | Baja | Usar --shrink en release builds |

---

## 9. ESTADO ACTUAL Y PRÓXIMOS PASOS

✅ Análisis arquitectura completado  
✅ Features identificadas  
✅ Pantallas mapeadas  
✅ Plugins críticos catalogados  
✅ Decisión: Flutter  

**Próximos pasos:**
1. ⏭️ Crear branch `migration/flutter`  
2. ⏭️ Inicializar estructura Flutter  
3. ⏭️ Comenzar FASE 1  

---

## 10. CHECKPOINTS DE VALIDACIÓN

- [ ] FASE 1: Proyecto Flutter running sin errores
- [ ] FASE 2: Routing y navigation funcionando
- [ ] FASE 3: Base de datos migrada completamente
- [ ] FASE 4: GPS tracking funcionando en device
- [ ] FASE 5: Sensores BLE conectando
- [ ] FASE 6: Sincronización servidor OK
- [ ] FASE 7: UI principal visible
- [ ] FASE 8: Configuración funcional
- [ ] FASE 9: Features avanzadas trabajando
- [ ] FASE 10: Tests pasando
- [ ] FASE 11: Release build exitoso

---

**Documento de referencia:** Este MD se actualizará conforme avance la migración
