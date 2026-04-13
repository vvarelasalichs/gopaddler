import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/session.dart';
import '../../../data/services/sync_service.dart';
import '../../../utils/app_logger.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  Session? _currentSession;
  final SyncService? _syncService;

  SessionBloc({SyncService? syncService})
      : _syncService = syncService,
        super(const SessionInitial()) {
    on<StartSessionEvent>(_onStartSession);
    on<StopSessionEvent>(_onStopSession);
    on<PauseSessionEvent>(_onPauseSession);
    on<ResumeSessionEvent>(_onResumeSession);
    on<AddGpsPointEvent>(_onAddGpsPoint);
    on<UpdateMeasurementEvent>(_onUpdateMeasurement);
    on<LoadSessionEvent>(_onLoadSession);
    on<RequestSessionSyncEvent>(_onSyncSession);
  }

  Future<void> _onStartSession(
    StartSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      _currentSession = Session(
        id: const Uuid().v4(),
        startTime: DateTime.now(),
        sportType: event.sportType,
        boatType: event.boatType,
        settings: SessionSettings(),
      );

      emit(SessionInProgress(session: _currentSession!));
    } catch (e) {
      emit(SessionError('Error starting session: $e'));
    }
  }

  Future<void> _onStopSession(
    StopSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const SessionError('No active session'));
        return;
      }

      _currentSession!.endTime = DateTime.now();
      final duration = _currentSession!.duration;
      final distance = _currentSession!.totalDistance;
      final avgSpeed = _currentSession!.averageSpeed;

      emit(SessionCompleted(
        session: _currentSession!,
        totalDuration: duration,
        totalDistance: distance,
        averageSpeed: avgSpeed,
      ));

      // Queue session for synchronization
      if (_syncService != null && _currentSession != null) {
        try {
          await _syncService!.queueSessionForSync(_currentSession!.id);
          AppLogger.info(
            'Session queued for sync: ${_currentSession!.id}',
            tag: 'SessionBloc',
          );
        } catch (e) {
          AppLogger.error(
            'Failed to queue session for sync',
            tag: 'SessionBloc',
            exception: e,
          );
        }
      }

      _currentSession = null;
    } catch (e) {
      emit(SessionError('Error stopping session: $e'));
    }
  }

  Future<void> _onPauseSession(
    PauseSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const SessionError('No active session'));
        return;
      }

      emit(SessionPaused(
        session: _currentSession!,
        elapsed: _currentSession!.duration,
      ));
    } catch (e) {
      emit(SessionError('Error pausing session: $e'));
    }
  }

  Future<void> _onResumeSession(
    ResumeSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const SessionError('No active session'));
        return;
      }

      emit(SessionInProgress(
        session: _currentSession!,
        elapsed: _currentSession!.duration,
      ));
    } catch (e) {
      emit(SessionError('Error resuming session: $e'));
    }
  }

  Future<void> _onAddGpsPoint(
    AddGpsPointEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) return;

      final point = GpsPoint(
        latitude: event.latitude,
        longitude: event.longitude,
        altitude: event.altitude,
        accuracy: 0,
        speed: event.speed,
        heading: 0,
        timestamp: DateTime.now(),
      );

      _currentSession!.gpsPoints.add(point);

      if (state is SessionInProgress) {
        emit(SessionInProgress(session: _currentSession!));
      }
    } catch (e) {
      emit(SessionError('Error adding GPS point: $e'));
    }
  }

  Future<void> _onUpdateMeasurement(
    UpdateMeasurementEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) return;

      final measurement = Measurement(
        type: event.type,
        value: event.value,
        unit: event.unit,
        timestamp: DateTime.now(),
      );

      _currentSession!.measurements.add(measurement);

      if (state is SessionInProgress) {
        emit(SessionInProgress(session: _currentSession!));
      }
    } catch (e) {
      emit(SessionError('Error updating measurement: $e'));
    }
  }

  Future<void> _onLoadSession(
    LoadSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      emit(const SessionLoading());
      // TODO: Implementar carga desde base de datos
      emit(const SessionError('Not implemented yet'));
    } catch (e) {
      emit(SessionError('Error loading session: $e'));
    }
  }

  Future<void> _onSyncSession(
    RequestSessionSyncEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const SessionError('No session to sync'));
        return;
      }

      // TODO: Implementar sincronización con servidor
      _currentSession!.isSynced = true;
      emit(SessionSynced(_currentSession!));
    } catch (e) {
      emit(SessionError('Error syncing session: $e'));
    }
  }
}
