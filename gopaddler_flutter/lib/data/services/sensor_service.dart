import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../../utils/app_logger.dart';

/// Evento de sensor con valores x, y, z
class SensorEvent {
  final double x;
  final double y;
  final double z;

  SensorEvent({required this.x, required this.y, required this.z});

  @override
  String toString() => 'SensorEvent(x: $x, y: $y, z: $z)';
}

/// Servicio de sensores del dispositivo
class SensorService {
  static const String _tag = 'SensorService';

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  late StreamController<SensorEvent> _accelerometerController;
  late StreamController<SensorEvent> _gyroscopeController;

  SensorService() {
    _accelerometerController = StreamController<SensorEvent>.broadcast();
    _gyroscopeController = StreamController<SensorEvent>.broadcast();
  }

  /// Inicia stream de acelerómetro
  /// Retorna stream de eventos de aceleración en m/s²
  Stream<SensorEvent> startAccelerometerStream({int samplingPeriod = 100}) {
    try {
      AppLogger.info('Iniciando stream de acelerómetro', tag: _tag);

      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerController.add(
            SensorEvent(x: event.x, y: event.y, z: event.z),
          );
        },
        onError: (error) {
          AppLogger.error('Error en stream de acelerómetro',
              tag: _tag, exception: error);
          _accelerometerController.addError(error);
        },
      );

      return _accelerometerController.stream;
    } catch (e) {
      AppLogger.error('Error iniciando stream de acelerómetro',
          tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Inicia stream de giroscopio
  /// Retorna stream de eventos de rotación en rad/s
  Stream<SensorEvent> startGyroscopeStream({int samplingPeriod = 100}) {
    try {
      AppLogger.info('Iniciando stream de giroscopio', tag: _tag);

      _gyroscopeSubscription = gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeController.add(
            SensorEvent(x: event.x, y: event.y, z: event.z),
          );
        },
        onError: (error) {
          AppLogger.error('Error en stream de giroscopio',
              tag: _tag, exception: error);
          _gyroscopeController.addError(error);
        },
      );

      return _gyroscopeController.stream;
    } catch (e) {
      AppLogger.error('Error iniciando stream de giroscopio',
          tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Detiene todos los streams de sensores
  Future<void> stopSensorStreams() async {
    try {
      AppLogger.info('Deteniendo streams de sensores', tag: _tag);

      await _accelerometerSubscription?.cancel();
      await _gyroscopeSubscription?.cancel();

      _accelerometerSubscription = null;
      _gyroscopeSubscription = null;

      AppLogger.info('Streams de sensores detenidos', tag: _tag);
    } catch (e) {
      AppLogger.error('Error deteniendo streams', tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Cierra controllers y limpia recursos
  Future<void> dispose() async {
    try {
      AppLogger.info('Cerrando SensorService', tag: _tag);
      await stopSensorStreams();
      await _accelerometerController.close();
      await _gyroscopeController.close();
    } catch (e) {
      AppLogger.error('Error cerrando SensorService', tag: _tag, exception: e);
    }
  }
}
