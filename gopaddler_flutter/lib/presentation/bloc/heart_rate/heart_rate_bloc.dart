import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/app_logger.dart';

part 'heart_rate_event.dart';
part 'heart_rate_state.dart';

/// Configuración de zonas de entrenamiento
/// Basado en pulsaciones máximas (FCmax)
class HeartRateZones {
  // Porcentajes de FCmax para cada zona (aproximado)
  static const double recoveryMax = 0.60;
  static const double aerobicMax = 0.70;
  static const double thresholdMax = 0.85;
  static const double vo2maxMax = 1.0;

  static String getZone(int bpm, int? maxHR) {
    if (maxHR == null || maxHR == 0) {
      // Estimar FCmax por edad (220 - edad) si no se tiene
      // Para este caso, usamos un valor genérico
      maxHR = 190; // Promedio aproximado
    }

    final percentage = bpm / maxHR;

    if (percentage <= recoveryMax) {
      return 'recovery';
    } else if (percentage <= aerobicMax) {
      return 'aerobic';
    } else if (percentage <= thresholdMax) {
      return 'threshold';
    } else {
      return 'vo2max';
    }
  }

  static const Map<String, String> zoneNames = {
    'recovery': 'Recuperación',
    'aerobic': 'Aeróbico',
    'threshold': 'Umbral',
    'vo2max': 'VO2 Max',
  };
}

/// BLoC para monitoreo de frecuencia cardíaca
class HeartRateBloc extends Bloc<HeartRateEvent, HeartRateState> {
  final List<int> _bpmHistory = [];
  int? _maxHR;
  bool _isMonitoring = false;

  HeartRateBloc() : super(const HeartRateInitial()) {
    on<StartHeartRateMonitoringEvent>(_onStartMonitoring);
    on<StopHeartRateMonitoringEvent>(_onStopMonitoring);
    on<HeartRateUpdatedEvent>(_onHeartRateUpdated);
    on<HeartRateThresholdReachedEvent>(_onThresholdReached);
    on<HeartRateErrorEvent>(_onHeartRateError);
  }

  /// Inicia monitoreo de FC
  Future<void> _onStartMonitoring(
    StartHeartRateMonitoringEvent event,
    Emitter<HeartRateState> emit,
  ) async {
    try {
      AppLogger.info('Iniciando monitoreo de FC', tag: 'HeartRateBloc');
      _isMonitoring = true;
      _bpmHistory.clear();

      emit(const HeartRateMonitoring(
        bpm: 0,
        zone: 'recovery',
        avgBpm: 0,
        minBpm: 999,
        maxBpm: 0,
      ));
    } catch (e) {
      AppLogger.error('Error iniciando monitoreo',
          tag: 'HeartRateBloc', exception: e);
      emit(HeartRateError('Error iniciando monitoreo: $e'));
    }
  }

  /// Detiene monitoreo de FC
  Future<void> _onStopMonitoring(
    StopHeartRateMonitoringEvent event,
    Emitter<HeartRateState> emit,
  ) async {
    try {
      AppLogger.info('Deteniendo monitoreo de FC', tag: 'HeartRateBloc');
      _isMonitoring = false;
      _bpmHistory.clear();

      emit(const HeartRateInitial());
    } catch (e) {
      AppLogger.error('Error deteniendo monitoreo',
          tag: 'HeartRateBloc', exception: e);
      emit(HeartRateError('Error deteniendo monitoreo: $e'));
    }
  }

  /// Actualiza una lectura de FC
  Future<void> _onHeartRateUpdated(
    HeartRateUpdatedEvent event,
    Emitter<HeartRateState> emit,
  ) async {
    try {
      if (!_isMonitoring) {
        return;
      }

      final bpm = event.bpm;

      // Validar rango razonable (40-200 bpm)
      if (bpm < 40 || bpm > 200) {
        AppLogger.warning('FC fuera de rango: $bpm bpm', tag: 'HeartRateBloc');
        return;
      }

      _bpmHistory.add(bpm);

      // Mantener solo los últimos 60 datos para cálculos
      if (_bpmHistory.length > 60) {
        _bpmHistory.removeAt(0);
      }

      // Calcular estadísticas
      final avgBpm = _bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length;
      final minBpm = _bpmHistory.reduce((a, b) => a < b ? a : b);
      final maxBpm = _bpmHistory.reduce((a, b) => a > b ? a : b);

      // Determinar zona de entrenamiento
      final zone = HeartRateZones.getZone(bpm, _maxHR);

      AppLogger.debug(
          'FC: $bpm bpm | Zona: $zone | Promedio: ${avgBpm.toStringAsFixed(1)}',
          tag: 'HeartRateBloc');

      if (state is HeartRateMonitoring) {
        final currentState = state as HeartRateMonitoring;
        emit(currentState.copyWith(
          bpm: bpm,
          zone: zone,
          avgBpm: avgBpm,
          minBpm: minBpm,
          maxBpm: maxBpm,
        ));
      } else {
        emit(HeartRateMonitoring(
          bpm: bpm,
          zone: zone,
          avgBpm: avgBpm,
          minBpm: minBpm,
          maxBpm: maxBpm,
        ));
      }
    } catch (e) {
      AppLogger.error('Error actualizando FC',
          tag: 'HeartRateBloc', exception: e);
      emit(HeartRateError('Error actualizando FC: $e'));
    }
  }

  /// Maneja cambio de umbral
  Future<void> _onThresholdReached(
    HeartRateThresholdReachedEvent event,
    Emitter<HeartRateState> emit,
  ) async {
    final zone = event.zone;
    AppLogger.info('Zona de entrenamiento: ${HeartRateZones.zoneNames[zone]}',
        tag: 'HeartRateBloc');
  }

  /// Maneja errores
  Future<void> _onHeartRateError(
    HeartRateErrorEvent event,
    Emitter<HeartRateState> emit,
  ) async {
    AppLogger.error('Error de FC: ${event.message}', tag: 'HeartRateBloc');
    emit(HeartRateError(event.message));
  }

  /// Establece la FC máxima (para cálculos de zonas)
  void setMaxHeartRate(int maxHR) {
    _maxHR = maxHR;
    AppLogger.debug('FCmax establecida: $maxHR', tag: 'HeartRateBloc');
  }
}
