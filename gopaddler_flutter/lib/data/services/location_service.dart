import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_logger.dart';
import '../models/session.dart';

/// Servicio de localización que maneja GPS con geolocator
class LocationService {
  static const String _tag = 'LocationService';

  StreamSubscription<Position>? _positionStream;
  final List<GpsPoint> _gpsBuffer = [];
  int _gpsIntervalSeconds = 5;
  Position? _lastPosition;

  Future<bool> requestPermissions() async {
    try {
      AppLogger.info('Solicitando permisos de localización', tag: _tag);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Servicio de ubicación deshabilitado', tag: _tag);
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warning('Permisos de localización denegados', tag: _tag);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.error('Permisos de localización permanentemente denegados',
            tag: _tag);
        await Geolocator.openLocationSettings();
        return false;
      }

      AppLogger.info('Permisos de localización otorgados', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Error solicitando permisos', tag: _tag, exception: e);
      return false;
    }
  }

  /// Obtiene posición actual
  Future<GpsPoint?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      return _positionToGpsPoint(position);
    } catch (e) {
      AppLogger.error('Error obteniendo posición actual',
          tag: _tag, exception: e);
      return null;
    }
  }

  /// Inicia streaming de posiciones
  Stream<GpsPoint> startPositionStream({
    int intervalSeconds = 5,
    LocationAccuracy accuracy = LocationAccuracy.best,
  }) {
    _gpsIntervalSeconds = intervalSeconds;

    final StreamController<GpsPoint> controller = StreamController<GpsPoint>();

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: accuracy,
          distanceFilter: 0,
          intervalDuration: Duration(seconds: intervalSeconds),
        ),
      ).listen(
        (Position position) {
          final gpsPoint = _positionToGpsPoint(position);
          _lastPosition = position;
          _gpsBuffer.add(gpsPoint);
          controller.add(gpsPoint);

          AppLogger.debug(
            'GPS: (${gpsPoint.latitude}, ${gpsPoint.longitude}) - Speed: ${gpsPoint.speed.toStringAsFixed(2)} m/s',
            tag: _tag,
          );
        },
        onError: (error) {
          AppLogger.error('Error en stream de posiciones',
              tag: _tag, exception: error);
          controller.addError(error);
        },
      );

      AppLogger.info('Stream de posiciones iniciado', tag: _tag);
    } catch (e) {
      AppLogger.error('Error iniciando stream', tag: _tag, exception: e);
      controller.addError(e);
    }

    return controller.stream;
  }

  /// Detiene el streaming de posiciones
  Future<void> stopPositionStream() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      AppLogger.info('Stream de posiciones detenido', tag: _tag);
    } catch (e) {
      AppLogger.error('Error deteniendo stream', tag: _tag, exception: e);
    }
  }

  /// Obtiene buffer de puntos GPS colectados
  List<GpsPoint> getGpsBuffer() {
    return List.from(_gpsBuffer);
  }

  /// Limpia buffer de GPS
  void clearGpsBuffer() {
    _gpsBuffer.clear();
  }

  /// Calcula distancia entre dos puntos
  double calculateDistance(GpsPoint from, GpsPoint to) {
    return from.distanceTo(to);
  }

  /// Convierte Position de geolocator a GpsPoint
  GpsPoint _positionToGpsPoint(Position position) {
    return GpsPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          position.timestamp?.millisecondsSinceEpoch ?? 0),
    );
  }

  /// Obtiene última posición conocida
  Position? getLastPosition() => _lastPosition;

  /// Calcula velocidad promedio de buffer
  double getAverageSpeed() {
    if (_gpsBuffer.isEmpty) return 0.0;
    final totalSpeed =
        _gpsBuffer.fold<double>(0, (sum, point) => sum + point.speed);
    return totalSpeed / _gpsBuffer.length;
  }

  /// Calcula distancia total del buffer
  double getTotalDistance() {
    if (_gpsBuffer.length < 2) return 0.0;
    double distance = 0.0;
    for (int i = 0; i < _gpsBuffer.length - 1; i++) {
      distance += _gpsBuffer[i].distanceTo(_gpsBuffer[i + 1]);
    }
    return distance;
  }
}
