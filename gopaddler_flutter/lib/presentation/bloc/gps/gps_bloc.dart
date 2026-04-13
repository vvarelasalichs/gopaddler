import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/session.dart';
import '../../../data/services/location_service.dart';
import '../../../utils/app_logger.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  final LocationService _locationService;
  StreamSubscription<GpsPoint>? _positionStream;

  double _totalDistance = 0.0;
  double _totalSpeed = 0.0;
  int _pointCount = 0;
  GpsPoint? _lastPoint;

  GpsBloc({required LocationService locationService})
      : _locationService = locationService,
        super(const GpsInitial()) {
    on<RequestGpsPermissionsEvent>(_onRequestPermissions);
    on<StartGpsTrackingEvent>(_onStartTracking);
    on<StopGpsTrackingEvent>(_onStopTracking);
    on<GpsLocationReceivedEvent>(_onLocationReceived);
    on<GpsErrorEvent>(_onGpsError);
  }

  Future<void> _onRequestPermissions(
    RequestGpsPermissionsEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      emit(const GpsPermissionsRequesting());

      final granted = await _locationService.requestPermissions();

      if (granted) {
        emit(const GpsPermissionsGranted());
      } else {
        emit(const GpsPermissionsDenied(
            'Permisos de GPS denegados por el usuario'));
      }
    } catch (e) {
      AppLogger.error(
        'Error requesting GPS permissions',
        tag: 'GpsBloc',
        exception: e,
      );
      emit(GpsError('Error requesting permissions: $e'));
    }
  }

  Future<void> _onStartTracking(
    StartGpsTrackingEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      // Verificar permisos
      final hasPermission = await _locationService.requestPermissions();
      if (!hasPermission) {
        emit(const GpsPermissionsDenied('GPS permisos no disponibles'));
        return;
      }

      // Limpiar buffers previos
      _resetTracking();

      // Iniciar stream de posiciones
      _positionStream = _locationService
          .startPositionStream(
        intervalSeconds: event.intervalSeconds,
      )
          .listen(
        (GpsPoint point) {
          if (_lastPoint == null) {
            // Primer punto
            _lastPoint = point;
            emit(GpsTracking(
              latitude: point.latitude,
              longitude: point.longitude,
              altitude: point.altitude,
              speed: point.speed,
              accuracy: point.accuracy,
              totalDistance: 0.0,
              averageSpeed: 0.0,
              pointCount: 1,
            ));
          } else {
            // Puntos subsecuentes
            _pointCount++;
            final distance = _lastPoint!.distanceTo(point);
            _totalDistance += distance;
            _totalSpeed += point.speed;

            final avgSpeed = _totalSpeed / _pointCount;

            if (state is GpsTracking) {
              emit((state as GpsTracking).copyWith(
                latitude: point.latitude,
                longitude: point.longitude,
                altitude: point.altitude,
                speed: point.speed,
                accuracy: point.accuracy,
                totalDistance: _totalDistance,
                averageSpeed: avgSpeed,
                pointCount: _pointCount,
              ));
            } else {
              emit(GpsTracking(
                latitude: point.latitude,
                longitude: point.longitude,
                altitude: point.altitude,
                speed: point.speed,
                accuracy: point.accuracy,
                totalDistance: _totalDistance,
                averageSpeed: avgSpeed,
                pointCount: _pointCount,
              ));
            }

            _lastPoint = point;
          }
        },
        onError: (error) {
          AppLogger.error(
            'Error en GPS stream',
            tag: 'GpsBloc',
            exception: error,
          );
          add(GpsErrorEvent('Error en tracking: $error'));
        },
      );

      AppLogger.info('GPS tracking iniciado', tag: 'GpsBloc');
    } catch (e) {
      AppLogger.error(
        'Error starting GPS tracking',
        tag: 'GpsBloc',
        exception: e,
      );
      emit(GpsError('Error starting tracking: $e'));
    }
  }

  Future<void> _onStopTracking(
    StopGpsTrackingEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      await _locationService.stopPositionStream();

      final finalState = GpsStopped(
        pointCount: _pointCount,
        totalDistance: _totalDistance,
        averageSpeed: _pointCount > 0 ? _totalSpeed / _pointCount : 0.0,
      );

      emit(finalState);

      AppLogger.info(
        'GPS tracking detenido - Puntos: $_pointCount, Distancia: ${_totalDistance.toStringAsFixed(2)}m',
        tag: 'GpsBloc',
      );
    } catch (e) {
      AppLogger.error(
        'Error stopping GPS tracking',
        tag: 'GpsBloc',
        exception: e,
      );
      emit(GpsError('Error stopping tracking: $e'));
    }
  }

  void _onLocationReceived(
    GpsLocationReceivedEvent event,
    Emitter<GpsState> emit,
  ) {
    // Este evento es manejado internamente por el stream
  }

  void _onGpsError(
    GpsErrorEvent event,
    Emitter<GpsState> emit,
  ) {
    AppLogger.error('GPS Error: ${event.message}', tag: 'GpsBloc');
    emit(GpsError(event.message));
  }

  void _resetTracking() {
    _totalDistance = 0.0;
    _totalSpeed = 0.0;
    _pointCount = 0;
    _lastPoint = null;
  }

  @override
  Future<void> close() async {
    await _positionStream?.cancel();
    await _locationService.stopPositionStream();
    return super.close();
  }
}
