import 'dart:math';
import '../../utils/app_logger.dart';

/// Detector de brazadas (strokes) basado en acelerómetro
/// Migrado desde stroke-detector.js del proyecto Cordova original
class StrokeDetector {
  static const String _tag = 'StrokeDetector';

  // Configuración de calibración
  final double _noiseThreshold;
  final double _strokeThreshold;
  final int _minStrokeInterval;
  final int _maxStrokeInterval;

  // Buffer de aceleración
  final List<double> _accelBuffer = [];
  final int _bufferSize = 20;

  // Estadísticas
  int _strokeCount = 0;
  DateTime? _lastStrokeTime;
  double _avgStrokeRate = 0.0;
  final List<int> _strokeIntervals = [];

  StrokeDetector({
    double noiseThreshold = 0.5,
    double strokeThreshold = 2.0,
    int minStrokeInterval = 300, // ms
    int maxStrokeInterval = 3000, // ms
  })  : _noiseThreshold = noiseThreshold,
        _strokeThreshold = strokeThreshold,
        _minStrokeInterval = minStrokeInterval,
        _maxStrokeInterval = maxStrokeInterval {
    AppLogger.info('StrokeDetector initialized', tag: _tag);
  }

  /// Procesa lectura de acelerómetro
  bool processAccelerometerData(double x, double y, double z) {
    // Calcular magnitud del vector de aceleración
    final magnitude = sqrt(x * x + y * y + z * z);

    // Añadir al buffer
    _accelBuffer.add(magnitude);
    if (_accelBuffer.length > _bufferSize) {
      _accelBuffer.removeAt(0);
    }

    // Detectar si hay suficientes datos
    if (_accelBuffer.length < 5) return false;

    // Calcular desviación estándar (indicador de movimiento)
    final stdDev = _calculateStdDev();

    // Detectar pico de aceleración (indicador de brazada)
    if (_isPeak() && stdDev > _strokeThreshold) {
      return _registerStroke();
    }

    return false;
  }

  /// Verifica si hay un pico en los últimos datos
  bool _isPeak() {
    if (_accelBuffer.length < 3) return false;

    final mid = _accelBuffer.length ~/ 2;
    final prev = _accelBuffer[mid - 1];
    final current = _accelBuffer[mid];
    final next = _accelBuffer[mid + 1];

    return current > prev && current > next && current > _noiseThreshold;
  }

  /// Registra una brazada detectada
  bool _registerStroke() {
    final now = DateTime.now();

    // Validar intervalo mínimo entre brazadas
    if (_lastStrokeTime != null) {
      final interval = now.difference(_lastStrokeTime!).inMilliseconds;

      if (interval < _minStrokeInterval) {
        return false; // Demasiado rápido, probablemente ruido
      }

      if (interval <= _maxStrokeInterval) {
        _strokeIntervals.add(interval);
        // Mantener solo últimas 10 brazadas para cálculo
        if (_strokeIntervals.length > 10) {
          _strokeIntervals.removeAt(0);
        }
        _updateStrokeRate();
      }
    }

    _strokeCount++;
    _lastStrokeTime = now;

    AppLogger.debug(
      'Stroke detected #$_strokeCount (Rate: ${_avgStrokeRate.toStringAsFixed(1)} strokes/min)',
      tag: _tag,
    );

    return true;
  }

  /// Actualiza cadencia de brazadas (strokes/min)
  void _updateStrokeRate() {
    if (_strokeIntervals.isEmpty) {
      _avgStrokeRate = 0.0;
      return;
    }

    final avgInterval =
        _strokeIntervals.reduce((a, b) => a + b) / _strokeIntervals.length;
    _avgStrokeRate =
        (60000 / avgInterval); // Convertir de ms a strokes por minuto
  }

  /// Calcula desviación estándar
  double _calculateStdDev() {
    if (_accelBuffer.length < 2) return 0.0;

    final mean = _accelBuffer.reduce((a, b) => a + b) / _accelBuffer.length;
    final variance = _accelBuffer
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) /
        _accelBuffer.length;

    return sqrt(variance);
  }

  /// Calibra el detector según datos del usuario
  void calibrate({
    required double noiseLevel,
    required double expectedStrokeForce,
  }) {
    AppLogger.info(
      'Calibrating: noise=$noiseLevel, force=$expectedStrokeForce',
      tag: _tag,
    );
    // Los umbrales podrían ajustarse dinámicamente según calibración
    // Por ahora mantenemos los valores iniciales
  }

  // Getters

  int get strokeCount => _strokeCount;
  double get strokeRate => _avgStrokeRate;
  DateTime? get lastStrokeTime => _lastStrokeTime;

  int get totalIntervals => _strokeIntervals.length;

  /// Reinicia el detector
  void reset() {
    _accelBuffer.clear();
    _strokeCount = 0;
    _lastStrokeTime = null;
    _avgStrokeRate = 0.0;
    _strokeIntervals.clear();
    AppLogger.debug('StrokeDetector reset', tag: _tag);
  }

  /// Obtiene estadísticas
  Map<String, dynamic> getStats() {
    return {
      'totalStrokes': _strokeCount,
      'strokeRate': _avgStrokeRate,
      'lastStroke': _lastStrokeTime?.toIso8601String(),
      'avgInterval': _strokeIntervals.isNotEmpty
          ? _strokeIntervals.reduce((a, b) => a + b) / _strokeIntervals.length
          : 0,
    };
  }
}
