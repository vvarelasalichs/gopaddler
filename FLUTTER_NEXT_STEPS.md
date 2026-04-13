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

## 📍 FASE 5: Bluetooth & Sensores (Estimado 2 días)

## 🔄 Actualizar Plan Conforme Avances

Cuando termines cada FASE:

1. Actualiza el `MIGRATION_PLAN.md` con el checkbox
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

## 📊 Timeline Estimado

| Fase | Duración | Estado |
|------|----------|--------|
| 1. Preparación | 1 día | ✅ COMPLETADA |
| 2. Arquitectura Base | 2 días | ✅ COMPLETADA |
| 3. Base de Datos | 1 día | ✅ COMPLETADA |
| 4. GPS & Tracking | 2 días | ⏭️ Próxima |
| 5. Bluetooth & Sensores | 2 días | ⏺️ Pendiente |
| 6. Sincronización | 1 día | ⏺️ Pendiente |
| 7-8. UI Principal | 5 días | ⏺️ Pendiente |
| 9. Features Avanzadas | 2 días | ⏺️ Pendiente |
| 10-11. Testing & Release | 3 días | ⏺️ Pendiente |
| **TOTAL** | **19 días** | ⏳ En progreso (Fase 3 completada)

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
