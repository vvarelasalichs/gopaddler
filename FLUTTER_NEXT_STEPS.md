# Instrucciones para Continuar con la Migración

## Status Actual

La **FASE 1** ha sido completada exitosamente. Se han realizado las siguientes acciones:

✅ **Análisis completo** del proyecto Cordova actual  
✅ **Plan detallado** de migración a Flutter  
✅ **Rama de migración** creada: `migration/flutter`  
✅ **Estructura inicial** de proyecto Flutter  
✅ **Archivos de configuración** y modelos básicos  
✅ **Documentación** actualizada  

---

## 📋 Requisitos para Continuar

Para poder continuar con la migración, necesitas instalar **Flutter** en tu máquina.

### Windows

#### Opción A: Direct Download (Recomendado)
1. Descargar Flutter desde: https://flutter.dev/docs/get-started/install/windows
2. Extraer a una carpeta (ej: `C:\flutter`)
3. Agregar al PATH en Variables de Entorno:
   - Sistema > Configuración avanzada del sistema > Variables de entorno
   - Nueva variable: `FLUTTER_HOME` = `C:\flutter`
   - Agregar `%FLUTTER_HOME%\bin` al PATH

#### Opción B: GitHub
```bash
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

### Verificar Instalación

```bash
flutter doctor
```

Deberá mostrar:
```
✓ Flutter (Channel stable)
✓ Android toolchain
✓ Android Studio
...
```

---

## 🚀 Próximos Pasos

### 1. Descargar Dependencias del Proyecto Flutter

```bash
cd gopaddler/gopaddler_flutter
flutter pub get
```

### 2. Verificar que el Proyecto Compila

```bash
flutter analyze
```

No debería haber errores críticos.

### 3. Crear un Emulador o Conectar un Device

**Opción A: Android Emulator**
```bash
flutter emulators
flutter emulators launch <emulator_name>
```

**Opción B: Device Real**
- Conectar device por USB
- Habilitar "Instalación desde fuentes desconocidas"
- Habilitar "Opciones de Desarrollador" y "Depuración USB"

### 4. Ejecutar la Aplicación

```bash
flutter run
```

Deberías ver la pantalla de inicio de GoPaddler.

### 5. Hot Reload

Una vez ejecutando:
- Presionar `r` para hot reload
- Presionar `R` para hot restart
- Presionar `q` para salir

---

## 📍 FASE 2: Arquitectura Base (Estimado 2 días)

### Objetivos
- [x] Routing funcional
- [x] State management con BLoC/Provider
- [x] Inyección de dependencias (GetIt)
- [x] Configuración multiambiente (dev/prod)
- [x] Logger y debugging

### Tareas
- [x] Implementar BLoC para manejo de estado (SessionBloc, SettingsBloc)
- [x] Crear service locator (GetIt)
- [x] Configurar ambientes (dev, prod, staging)
- [x] Agregar logging sistema-wide

### Commit
```
FASE 2: Arquitectura Base - BLoC, GetIt, Configuración multiambiente y Logging
SHA: d0238e0
```

---

## 📍 FASE 3: Base de Datos (Estimado 1 día)

### Objetivos
- [x] Migración de schema SQLite
- [x] Setup sqflite
- [x] Modelos con serialización JSON
- [x] Repository de persistencia

### Tareas
- [x] Definir modelos Dart completamente con toMap/fromMap/toJson/fromJson
- [x] Crear DatabaseService con sqflite
- [x] Implementar repositories (SessionRepository)
- [x] Crear migrations y schema

### Commit
```
FASE 3: Base de Datos - Modelos JSON, DatabaseService, Repositories y Migrations
SHA: 5982f8e
```

### Detalles Implementados
- **Modelos mejorados**: Session, GpsPoint, Measurement, Split, HeartRateZone, SessionSettings
  - Cada modelo incluye: toMap(), fromMap(), toJson(), fromJson()
  - Soporte para serializacion bidireccional (DB ↔ JSON)
- **DatabaseService**: 
  - Tabla sessions: almacena datos básicos de sesiones
  - Tabla gps_points: relación FK con sessions
  - Tabla measurements: relación FK con sessions
  - Índices para optimizar queries
  - CRUD operations completas
  - Manejo de errores con logging
- **SessionRepository**: Pattern Repository para abstracción de datos
  - Métodos: saveSession, getSessionById, getAllSessions, updateSession, deleteSession
  - Carga de datos relacionados automáticamente
  - Gestión de transacciones cuando es necesario

---

## 📍 FASE 4: GPS & Tracking (Completada ✅ 2 días)

### Objetivos
- [x] Geolocalización funcionando
- [x] GPS tracking en tiempo real (LocationService)
- [x] Detector de strokes migrado (StrokeDetector)
- [x] Pantalla de sesión activa (SessionActivePage)
- [x] BLoC para orquestar GPS (GpsBloc)

### Tareas Completadas
1. ✅ Integración geolocator package
2. ✅ LocationService: streaming de posiciones, manejo de permisos, buffer de puntos
3. ✅ Migración de stroke detector algorithm de Cordova
4. ✅ GpsBloc: orquestar LocationService y estados de tracking
5. ✅ SessionActivePage: UI con métricas en tiempo real
6. ✅ Registrar LocationService y GpsBloc en ServiceLocator
7. ✅ Agregar GpsBloc a MultiBlocProvider en main.dart

### Detalles Implementados
- **LocationService** (lib/data/services/location_service.dart):
  - Gestión de permisos GPS con validación de estado
  - Streaming de posiciones con intervalo configurable (default 5s)
  - Buffer automático de puntos GPS para cálculos de distancia/velocidad
  - Cálculo de distancia total con fórmula Haversine
  - Métodos: requestPermissions, getCurrentPosition, startPositionStream, stopPositionStream
  
- **StrokeDetector** (lib/domain/services/stroke_detector.dart):
  - Detecta strokes a partir de datos acelerómetro (magnitud x,y,z)
  - Buffer circular de 20 muestras para suavizado de ruido
  - Detección de picos con thresholds configurables
  - Validación de intervalos mínimo/máximo entre strokes
  - Cálculo automático de stroke rate (strokes/minute)
  - Métodos: processAccelerometerData, getStats, calibrate
  - Migrado desde Cordova stroke-detector.js
  
- **GpsBloc** (lib/presentation/bloc/gps/gps_bloc.dart):
  - Eventos: RequestGpsPermissionsEvent, StartGpsTrackingEvent, StopGpsTrackingEvent, GpsLocationReceivedEvent, GpsErrorEvent
  - Estados: GpsInitial, GpsPermissionsRequesting, GpsPermissionsDenied, GpsPermissionsGranted, GpsTracking, GpsStopped, GpsError
  - Orquestación automática de LocationService
  - Cálculo continuo de métricas: distancia total, velocidad promedio, conteo de puntos
  - Cleanup automático en close()
  
- **SessionActivePage** (lib/presentation/pages/session_active_page.dart):
  - Estados visuales: Initial, PermissionsRequesting, PermissionsDenied, PermissionsGranted, Tracking, Stopped, Error
  - Visualización de métricas en tiempo real: distancia, velocidad, altitud, precisión
  - Posición GPS actual (lat/lon con 6 decimales)
  - Contador de puntos recopilados
  - Botones: Iniciar Tracking, Detener Tracking, Guardar/Descartar sesión
  - Uso de BlocListener para notificaciones de error
  - Widget helper _buildMetricCard para componentes reutilizables

### Commits
```
e57686f: FASE 4: Crear GpsBloc para orquestar LocationService
3e3e649: FASE 4: Implementar UI para Sesión Activa con métricas GPS en tiempo real
```

---

## 📍 FASE 5: Bluetooth & Sensores (Completada ✅ 2 días)

### Objetivos
- [x] Conectividad Bluetooth BLE funcional
- [x] Lectura de sensores (acelerómetro/giroscopio)
- [x] Sincronización de dispositivos BLE
- [x] UI para gestión de dispositivos

### Tareas Completadas
1. ✅ Crear BluetoothService con flutter_blue_plus
2. ✅ Crear BluetoothBloc/Event/State para orquestar BLE
3. ✅ Crear HeartRateBloc/Event/State con zonas HR
4. ✅ Crear SensorService para acelerómetro/giroscopio
5. ✅ Implementar BluetoothPage UI mejorada
6. ✅ Integrar GpsBloc + BluetoothBloc para metrics en tiempo real
7. ✅ Actualizar SessionActivePage con HR y cadencia
8. ✅ Registrar servicios en ServiceLocator
9. ✅ Agregar BLoCs a MultiBlocProvider
10. ✅ Instalar dependencias: flutter_blue_plus, sensors_plus

### Detalles Implementados
- **BluetoothService** (lib/data/services/bluetooth_service.dart):
  - Métodos: requestPermissions(), startScan(), stopScan(), connectDevice(), disconnectDevice()
  - Streams: subscribeToHeartRate(), subscribeToCadence()
  - Manejo de dispositivos BLE con flutter_blue_plus
  - Control de permisos y errores con AppLogger
  
- **BluetoothBloc** (lib/presentation/bloc/bluetooth/):
  - Eventos: RequestBluetoothPermissionsEvent, StartBluetoothScanEvent, StopBluetoothScanEvent, ConnectDeviceEvent, DisconnectDeviceEvent, BluetoothDeviceFoundEvent, HeartRateReceivedEvent, CadenceReceivedEvent, BluetoothErrorEvent
  - Estados: BluetoothInitial, BluetoothPermissionRequesting, BluetoothPermissionDenied, BluetoothPermissionGranted, BluetoothScanning, BluetoothConnecting, BluetoothConnected, BluetoothDisconnected, BluetoothError
  - Orquestación completa de BluetoothService
  
- **HeartRateBloc** (lib/presentation/bloc/heart_rate/):
  - Eventos: HeartRateUpdatedEvent, HeartRateThresholdReachedEvent
  - Estados: HeartRateInitial, HeartRateMonitoring (con bpm, zona, avg, min, max), HeartRateError
  - Cálculo automático de zonas de entrenamiento (recovery, aerobic, threshold, vo2max)
  - Estadísticas en tiempo real
  
- **SensorService** (lib/data/services/sensor_service.dart):
  - Streams de acelerómetro (x, y, z)
  - Streams de giroscopio
  - Integración con sensors_plus package
  - Control de vida útil de streams
  
- **BluetoothPage UI** (lib/presentation/pages/bluetooth_page.dart):
  - Solicitud de permisos BLE
  - Interfaz de escaneo con lista de dispositivos
  - Lista de dispositivos conectados
  - Indicadores de señal (RSSI)
  - Botones de conectar/desconectar
  - Visualización de HR y cadencia en tiempo real
  
- **Integración GpsBloc + HeartRateBloc**:
  - GpsTracking state ahora incluye heartRate y cadence opcionales
  - SessionActivePage muestra métricas HR y cadencia durante GPS tracking
  - Combinación de GPS + sensores biométricos para análisis completo

### Commits  
```
7b72651: FASE 5: Implementar Bluetooth & Sensores - BLoCs, Services, UI integrada
```

### Dependencias Instaladas
```yaml
flutter_blue_plus: ^1.29.5
sensors_plus: ^1.9.5
```

---

## 📍 FASE 6: Sincronización (Estimado 1 día)

### Objetivos
- [ ] Sincronización de sesiones con servidor
- [ ] Almacenamiento local de sesiones sin sincronizar
- [ ] Integración Strava
- [ ] WebSocket para sync en tiempo real

#### 5.1 Crear BluetoothService
**Archivo:** `lib/data/services/bluetooth_service.dart`
- Clase BluetoothService con métodos:
  - `requestPermissions()`: Solicitar permisos BLE
  - `startScan(duration)`: Escanear dispositivos disponibles
  - `stopScan()`: Detener escaneo
  - `connectDevice(deviceId, type)`: Conectar a dispositivo (HR o Cadence)
  - `disconnectDevice(deviceId)`: Desconectar dispositivo
  - `subscribeToHeartRate()`: Stream de datos HR
  - `subscribeToCadence()`: Stream de datos de cadencia
  - `getConnectedDevices()`: Listar dispositivos conectados
- Manejo de errores con AppLogger
- Estados de conexión: connecting, connected, disconnected, error

#### 5.2 Crear BluetoothBloc
**Archivo:** `lib/presentation/bloc/bluetooth/bluetooth_bloc.dart` (3 archivos: bloc.dart, event.dart, state.dart)
- Eventos: RequestBluetoothPermissionsEvent, StartBluetoothScanEvent, StopBluetoothScanEvent, ConnectDeviceEvent, DisconnectDeviceEvent, BluetoothDeviceFoundEvent, HeartRateReceivedEvent, CadenceReceivedEvent, BluetoothErrorEvent
- Estados: BluetoothInitial, BluetoothPermissionRequesting, BluetoothPermissionDenied, BluetoothPermissionGranted, BluetoothScanning, BluetoothConnecting, BluetoothConnected, BluetoothDisconnected, BluetoothError
- Integración con BluetoothService para streaming

#### 5.3 Crear HeartRateBloc (opcional)
**Archivo:** `lib/presentation/bloc/heart_rate/heart_rate_bloc.dart` (3 archivos)
- Eventos: HeartRateUpdatedEvent, HeartRateThresholdReachedEvent
- Estados: HeartRateInitial, HeartRateMonitoring, HeartRateError
- Cálculo de zonas de entrenamiento

#### 5.4 Crear SensorService
**Archivo:** `lib/data/services/sensor_service.dart`
- Usar `sensors_plus` package
- Métodos: startAccelerometerStream(), startGyroscopeStream(), stopSensorStreams()
- Integración con StrokeDetector

#### 5.5 Crear BluetoothDevicePage (UI)
**Archivo:** `lib/presentation/pages/bluetooth_page.dart` (actualizar existente)
- Escaneo de dispositivos
- Lista de disponibles y conectados
- Botones conectar/desconectar
- Indicador de señal (rssi)

#### 5.6 Actualizar ServiceLocator
- Registrar BluetoothService como singleton
- Registrar SensorService como singleton
- Registrar BluetoothBloc

#### 5.7 Actualizar main.dart
- Agregar BluetoothBloc a MultiBlocProvider

#### 5.8 Integración GpsBloc + BluetoothBloc
- Agregar HeartRate y Cadence a GpsTracking state
- Actualizar SessionActivePage para mostrar HR y cadencia

### Dependencias a Agregar
```yaml
flutter_blue_plus: ^1.29.5
sensors_plus: ^1.9.5
```

---

## 📍 FASE 6: Sincronización (Completada ✅ 1 día)

### Objetivos
- [x] Sincronización de sesiones con servidor
- [x] Almacenamiento local de sesiones sin sincronizar
- [x] Integración Strava
- [x] WebSocket para sync en tiempo real

### Tareas Completadas
1. ✅ Crear SyncQueue model para cola local
2. ✅ Crear SyncService con retry automático
3. ✅ Crear StravaIntegrationService OAuth2
4. ✅ Crear WebSocketService con auto-reconexión
5. ✅ Crear SyncBloc/Event/State para orquestar
6. ✅ Actualizar DatabaseService tabla sync_queue
7. ✅ Actualizar SettingsBloc con autoSync y syncOnWiFiOnly
8. ✅ Actualizar SessionBloc integración SyncBloc
9. ✅ Registrar servicios en ServiceLocator
10. ✅ Agregar SyncBloc a MultiBlocProvider
11. ✅ Instalar dependencias: web_socket_channel, http

### Detalles Implementados
- **SyncQueue Model** (lib/data/models/sync_queue.dart):
  - Campos: sessionId (FK), timestamp, status (pending/syncing/completed/failed), retryCount, lastError, lastSyncAttempt
  - Serialización completa: toMap(), fromMap(), toJson(), fromJson()
  - Enum para estados de sincronización

- **SyncService** (lib/data/services/sync_service.dart):
  - uploadSession(sessionId): sube sesión al servidor
  - downloadSessions(): descarga sesiones sincronizadas
  - queueSessionForSync(sessionId): agrega a cola local
  - getSyncQueue(): obtiene pendientes
  - clearSyncQueue(sessionId): remueve de cola después del sync
  - uploadWithRetry(sessionId, maxRetries): reintentos con backoff exponencial (1s * 2^retryCount)
  - checkSyncStatus(sessionId): obtiene estado actual
  - Gestión de conexión WiFi/Mobile
  - AppLogger para tracking de intentos

- **StravaIntegrationService** (lib/data/services/strava_service.dart):
  - authenticate(authCode): OAuth2 code exchange
  - uploadActivity(session): POST a Strava API
  - getAthleteProfile(): GET datos del atleta
  - fetchActivities(limit): sincronización de actividades
  - refreshToken(): renovación automática de tokens
  - Gestión de tokens en SharedPreferences
  - Manejo de timeouts de 30 segundos

- **WebSocketService** (lib/data/services/websocket_service.dart):
  - connect(): establece conexión WS
  - disconnect(): cierra conexión
  - send(message): envía mensajes
  - onMessage: stream de mensajes recibidos
  - Auto-reconexión con backoff: 1s, 2s, 4s, 8s, máx 30s
  - Heartbeat cada 30 segundos para detectar conexiones muertas
  - Logging completo de eventos WS

- **SyncBloc** (lib/presentation/bloc/sync/):
  - Eventos: SyncSessionEvent, SyncAllQueuedEvent, CheckSyncStatusEvent, SyncProgressEvent, SyncErrorEvent, SyncSuccessEvent, UploadToStravaEvent
  - Estados: SyncInitial, SyncInProgress (con progreso), SyncCompleted, SyncError, SyncQueueStatus, SyncSuccess
  - Escucha SessionBloc para detectar sesiones completadas
  - Auto-sync en background si autoSync está habilitado
  - Emite eventos de progreso periódicamente

- **DatabaseService Updates**:
  - Tabla `sync_queue` con campos completos
  - Índice en sessionId para queries rápidas
  - FK con cascading deletes
  - Métodos: insertSyncQueue, getSyncQueue, updateSyncStatus, removeSyncQueue

- **SettingsBloc Updates**:
  - Nuevos eventos: UpdateAutoSyncEvent, UpdateSyncOnWiFiOnlyEvent  
  - Campos en AppSettings: autoSync (default true), syncOnWiFiOnly (default false)
  - Persistencia en SharedPreferences

- **SessionBloc Updates**:
  - Integración con SyncBloc en completar sesión
  - Agrega automáticamente sesión a cola de sync
  - Escucha eventos de SyncBloc para marcar como sincronizadas

### Commits
```
9c7dd55: FASE 6: Implementar Sincronización - Services, BLoCs y Integración
```

### Dependencias Instaladas
```yaml
web_socket_channel: ^2.4.0
http: ^1.1.0
shared_preferences: ^2.2.0
```

---

## 📍 FASE 7: UI Principal - Sesiones (Estimado 3 días)
**Archivo:** `lib/data/services/sync_service.dart`
- Métodos: uploadSession, downloadSessions, queueSessionForSync, getSyncQueue, clearSyncQueue, checkSyncStatus
- Gestión de conexión (WiFi/Mobile data)
- Retry automático con backoff exponencial

#### 6.2 Crear SyncBloc
**Archivo:** `lib/presentation/bloc/sync/sync_bloc.dart` (3 archivos)
- Eventos: SyncSessionEvent, SyncAllQueuedEvent, CheckSyncStatusEvent, SyncProgressEvent, SyncErrorEvent, SyncSuccessEvent
- Estados: SyncInitial, SyncInProgress, SyncCompleted, SyncError, SyncQueueStatus

#### 6.3 Crear StravaIntegrationService
**Archivo:** `lib/data/services/strava_service.dart`
- OAuth2 con Strava
- Métodos: authenticate, uploadActivity, getAthleteProfile, fetchActivities
- Gestión de tokens y refresh

#### 6.4 Crear SyncQueueModel
**Archivo:** `lib/data/models/sync_queue.dart`
- Modelo para sesiones pendientes: sessionId, timestamp, status, retryCount, lastError

#### 6.5 Actualizar DatabaseService
- Agregar tabla `sync_queue` con FK a sessions
- Métodos: insertSyncQueue, getSyncQueue, updateSyncStatus, removeSyncQueue

#### 6.6 Crear WebSocketService
**Archivo:** `lib/data/services/websocket_service.dart`
- Usar `web_socket_channel` package
- Auto-reconexión con backoff

#### 6.7 Actualizar SettingsBloc
- Agregar autoSync y syncOnWifi a AppSettings

#### 6.8 Actualizar SessionBloc
- Integración con SyncBloc post-sesión

### Dependencias a Agregar
```yaml
web_socket_channel: ^2.4.0
http: ^1.1.0
```

---

## ✅ FASE 7: UI Principal - Sesiones (Completado ✓ - 1 día)

### Estado: COMPLETADO

**Archivos Creados:**
1. ✅ lib/presentation/widgets/chart_widgets.dart - SpeedChart, HeartRateChart widgets con fl_chart
2. ✅ lib/presentation/widgets/session_map.dart - SessionMap con flutter_map
3. ✅ lib/presentation/widgets/stat_card.dart - StatCard reusable widget
4. ✅ lib/presentation/widgets/current_session_card.dart - CurrentSessionCard with session state
5. ✅ lib/domain/models/training_zones.dart - TrainingZone model with HR zones

**Archivos Actualizados:**
1. ✅ lib/presentation/pages/home_page.dart - HomePage with HomeStats and CurrentSessionCard
2. ✅ lib/presentation/pages/sessions_page.dart - SessionsPage with filters, search, and swipe delete
3. ✅ lib/presentation/pages/session_summary_page.dart - 5 tabs (Overview, Charts, Map, Splits, Analysis)
4. ✅ lib/data/models/session.dart - Added notes field and getEfficiencyScore() method
5. ✅ lib/config/routes.dart - Fixed SessionSummaryPage route to use session object
6. ✅ pubspec.yaml - Added all UI dependencies (fl_chart, flutter_map, intl, etc)

**Dependencias Agregadas:**
- ✅ fl_chart: ^0.63.0 (Charts: Line, Bar, Pie)
- ✅ flutter_map: ^4.0.0 (Maps and routing)
- ✅ intl: ^0.20.2 (Internacionalization)
- ✅ latlong2: ^0.8.2 (Map coordinates)
- ✅ share_plus: ^7.0.0 (Share sessions)
- ✅ flutter_slidable: ^3.0.0 (Swipe actions)

**Compilación:** ✅ PASS
- 0 CRITICAL ERRORS
- 113 total issues (mostly style suggestions - INFO level)
- All mandatory widgets and pages completed
- UI fully functional with BLoC integration

**Commit:** f0c0cb9 "FASE 7: Fix critical compilation errors and complete widgets"

## 📍 FASE 8: UI Principal - Configuración (Estimado 2 días)

### Objetivos
- [ ] SettingsPage completa funcional
- [ ] CalibrationPage para sensores
- [ ] ChooseBoatPage y ChooseSportPage
- [ ] ProfilePage de usuario

### Tareas Detalladas

#### 8.1 Implementar SettingsPage completa
**Archivo:** `lib/presentation/pages/settings_page.dart`
- Secciones: Perfil, Preferencias, Sesiones, Sync, Bluetooth, Información, Acerca de
- Preferencias: idioma, tema, unidades (km/millas)
- Sesiones: frecuencia GPS, tipo bote, deporte
- Sincronización: auto-sync, WiFi only, último sync, botón sincronizar
- Bluetooth: dispositivos emparejados, botón escanear

#### 8.2 Implementar CalibrationPage
**Archivo:** `lib/presentation/pages/calibration_page.dart`
- Calibración de acelerómetro, GPS, HR, cadencia
- Botón "Reset a valores por defecto"
- Instrucciones por sensor

#### 8.3 Crear ChooseBoatPage
**Archivo:** `lib/presentation/pages/choose_boat_page.dart`
- Opciones: Single kayak, Double kayak, Canoe, Dragon boat, SUP, Outrigger canoe
- Grid con iconos y selección

#### 8.4 Crear ChooseSportPage
**Archivo:** `lib/presentation/pages/choose_sport_page.dart`
- Opciones: Paddling, Cycling
- Afecta métricas mostradas

#### 8.5 Crear ProfilePage
**Archivo:** `lib/presentation/pages/profile_page.dart`
- Avatar, nombre, correo, estadísticas acumulativas
- Botón editar y cerrar sesión

#### 8.6 Crear UserModel
**Archivo:** `lib/data/models/user_model.dart`
- Campos: id, name, email, profileImageUrl, preferredUnit, boatType, sportType
- Serialización completa

#### 8.7 Crear UserRepository
**Archivo:** `lib/data/repositories/user_repository.dart`
- CRUD para usuario
- Integración con SharedPreferences

#### 8.8 Actualizar SettingsBloc
- Eventos: UpdateUserProfileEvent, UpdateBoatTypeEvent, UpdateSportTypeEvent
- Persistencia con SharedPreferences

### Dependencias a Agregar
```yaml
shared_preferences: ^2.2.0
image_picker: ^1.0.0
```

---

## 📍 FASE 9: Características Avanzadas (Estimado 2 días)

### Objetivos
- [ ] Gráficos y análisis avanzados
- [ ] Splits y intervalos
- [ ] Zonas de entrenamiento
- [ ] Coach profiles (opcional)

### Tareas Detalladas

#### 9.1 Crear AnalyticsService
**Archivo:** `lib/domain/services/analytics_service.dart`
- Cálculos: promedio móvil, esfuerzos máximos, distribución zonas HR, tendencias
- Métodos: calculateSessionStats, calculateZoneDistribution, getTrendAnalysis, compare

#### 9.2 Mejorar SplitsFeature
**Archivo:** `lib/domain/models/split.dart`
- Nombre/descripción de split
- Cálculos: pace, cadencia promedio

#### 9.3 Crear TrainingZonesModel
**Archivo:** `lib/domain/models/training_zones.dart`
- Zonas: recovery, aerobic, threshold, vo2max, anaerobic
- Cálculo automático basado en max HR
- Porcentaje de tiempo por zona

#### 9.4 Mejorar SessionSummaryPage
- Tab de análisis
- Eficiencia del entrenamiento (score)
- Esfuerzos máximos detectados
- Recomendaciones
- Comparativa con sesión previa

#### 9.5 Crear CoachProfilesPage (opcional)
**Archivo:** `lib/presentation/pages/coach_profiles_page.dart`
- Perfiles de coach
- Entrenamientos recomendados

#### 9.6 Integración Strava Enhanced
- Auto-sync post-sesión
- Compartir en redes sociales

---

## 📍 FASE 10: Testing Automatizado (Estimado 1.5 días)

### Objetivos
- [ ] Unit tests de servicios y BLoCs
- [ ] Widget tests de UI crítica
- [ ] Integration tests end-to-end

### Tareas Detalladas

#### 10.1 Unit Tests
**Carpeta:** `test/`
- test/data/services/: location_service, bluetooth_service, database_service, sync_service
- test/domain/services/: stroke_detector, analytics_service
- test/presentation/bloc/: session_bloc, gps_bloc, bluetooth_bloc, settings_bloc

Cobertura mínima: 70%

#### 10.2 Widget Tests
**Carpeta:** `test/presentation/pages/`
- home_page_test.dart
- session_active_page_test.dart
- session_summary_page_test.dart
- settings_page_test.dart

#### 10.3 Integration Tests
**Carpeta:** `integration_test/`
- app_test.dart: flujo completo sesión (permisos → start → tracking → stop → save)

### Dependencias
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  bloc_test: ^9.1.0
```

### Ejecución
```bash
flutter test                        # All tests
flutter test --coverage             # Coverage report
flutter drive --target=integration_test/app_test.dart
```

---

## 📍 FASE 11: Build & Release (Estimado 1.5 días)

### Objetivos
- [ ] APK release para Android
- [ ] App Bundle para Google Play
- [ ] IPA para iOS
- [ ] Documentación de release

### Tareas Detalladas

#### 11.1 Preparación Pre-Release
**Modificar:** `pubspec.yaml`
- Version: 1.0.0+1
- Description y autor

**Modificar:** `android/app/build.gradle`
- applicationId (ej: com.gopaddler.app)
- versionCode y versionName
- minSdkVersion: 21+

#### 11.2 Build APK
```bash
flutter build apk --release
flutter build apk --split-per-abi
```

#### 11.3 Build App Bundle
```bash
flutter build appbundle --release
```

#### 11.4 Firma de APK/Bundle
**Crear keystore:**
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias gopaddler
```

**Configurar** `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=gopaddler
storeFile=/path/to/key.jks
```

#### 11.5 iOS Build (requiere Mac)
```bash
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -derivedDataPath build -arch arm64
```

#### 11.6 Configuración Google Play Store
- Crear cuenta Google Play Developer ($25)
- Subir App Bundle
- Store listing: screenshots, descripción
- Privacidad y permisos

#### 11.7 Configuración Apple App Store
- Crear Apple Developer account
- TestFlight
- App store listing

#### 11.8 Documentación de Release
**Crear:** `RELEASE_NOTES.md`
- Historial versiones
- Features principales
- Bug fixes
- Requisitos: Android 5.0+, iOS 12+

#### 11.9 Performance Optimization
```bash
flutter build apk --split-debug-info=symbols/
flutter pub run devtools_extensions
```

#### 11.10 Setup CI/CD (GitHub Actions - opcional)
**Crear:** `.github/workflows/build.yml`
- Trigger: push a main
- Build automático
- Tests
- Upload a Play Store

### Checklist Final
- [ ] flutter analyze: 0 errores críticos
- [ ] flutter test: 70%+ cobertura
- [ ] APK testeado en device real
- [ ] IPA generado (si es posible)
- [ ] Cuentas Google Play y AppStore creadas
- [ ] RELEASE_NOTES.md completado
- [ ] Version actualizada
- [ ] Privacy policy y ToS listos

---

## 🔄 Actualizar Plan Conforme Avances

Cuando termines cada FASE:

1. Actualiza este documento con checkboxes completados
2. Commit con mensaje descriptivo:
   ```bash
   git add -A
   git commit -m "FASE X: Descripción de lo completado"
   git push origin migration/flutter
   ```
3. Documenta cualquier issue o bloqueo

---

## 🐛 Troubleshooting Común

### Error: "flutter: command not found"
```bash
# Verificar PATH
echo $PATH

# Agregar manualmente
export PATH="$PATH:/path/to/flutter/bin"
```

### Error: "Android SDK not found"
```bash
flutter config --android-sdk /path/to/android/sdk
```

### Error: "Gradle sync failed"
```bash
cd gopaddler_flutter
flutter clean
flutter pub get
flutter run
```

### Error en Kotlin/Java
```bash
# Limpiar completamente
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📞 Recursos Útiles

| Recurso | Link |
|---------|------|
| Flutter Docs | https://flutter.dev/docs |
| BLoC Pattern | https://bloclibrary.dev/ |
| GoRouter | https://pub.dev/packages/go_router |
| Sqflite | https://pub.dev/packages/sqflite |
| Flutter Blue Plus | https://pub.dev/packages/flutter_blue_plus |
| Geolocator | https://pub.dev/packages/geolocator |

---

## 💡 Tips de Desarrollo

### Hot Reload Eficiente
- Cambios en widgets se recargan instantáneamente
- Cambios en lógica requieren hot restart

### Debug Logging
```bash
flutter run -v  # Verbose logging
```

### Analizar Performance
```bash
flutter run --profile
```

### Build Release
```bash
flutter build apk --release
flutter build appbundle --release  # Para Google Play
```

---

## 📊 Timeline Estimado - Actualizado

| Fase | Duración | Estado |
|------|----------|--------|
| 1. Preparación | 1 día | ✅ COMPLETADA |
| 2. Arquitectura Base | 2 días | ✅ COMPLETADA |
| 3. Base de Datos | 1 día | ✅ COMPLETADA |
| 4. GPS & Tracking | 2 días | ✅ COMPLETADA |
| 5. Bluetooth & Sensores | 2 días | ✅ COMPLETADA |
| 6. Sincronización | 1 día | ✅ COMPLETADA |
| 7. UI - Sesiones | 3 días | ⏺️ **PRÓXIMA** |
| 8. UI - Configuración | 2 días | ⏺️ Pendiente |
| 9. Características Avanzadas | 2 días | ⏺️ Pendiente |
| 10. Testing Automatizado | 1.5 días | ⏺️ Pendiente |
| 11. Build & Release | 1.5 días | ⏺️ Pendiente |
| **TOTAL** | **19 días** | ⏳ En progreso (6/11 completadas)

---

## ✅ Checklist Antes de Iniciar FASE 2

- [x] Flutter instalado y `flutter doctor` sin errores críticos
- [x] `flutter pub get` ejecutado exitosamente
- [x] `flutter analyze` sin errores críticos
- [x] `flutter run` funciona en Chrome
- [x] Hot reload funciona
- [x] Branch `migration/flutter` está activo

---

## ✅ Checklist FASE 3 Completada

- [x] **Modelos JSON**: Session, GpsPoint, Measurement, Split, HeartRateZone, SessionSettings
- [x] **DatabaseService**: sqflite con 3 tablas principales (sessions, gps_points, measurements)
- [x] **SessionRepository**: Pattern Repository para capa de datos
- [x] **Migrations**: Schema inicial con índices y foreign keys
- [x] **Service Locator**: DatabaseService y SessionRepository registrados
- [x] **Serialización**: toMap/fromMap/toJson/fromJson en todos los modelos

---

## 🎯 Objetivo Final

Al completar todas las fases tendremos:
- ✅ Aplicación Flutter totalmente funcional
- ✅ Compatibilidad con Android e iOS
- ✅ Todas las features del original Cordova
- ✅ Mejor performance y experiencia de usuario
- ✅ Código mantenible y escalable
- ✅ Testing automatizado

---

**¿Listo? ¡Instala Flutter y comienza la FASE 2!**

Referencia: `gopaddler_flutter/README.md` para más detalles.
