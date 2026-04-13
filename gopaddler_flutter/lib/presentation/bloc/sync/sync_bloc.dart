import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/sync_queue.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/services/strava_service.dart';
import '../../../data/services/websocket_service.dart';
import '../../../utils/app_logger.dart';

part 'sync_event.dart';
part 'sync_state.dart';

/// BLoC for managing session synchronization
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  static const String _tag = 'SyncBloc';

  final SyncService _syncService;
  final StravaIntegrationService _stravaService;
  final WebSocketService _webSocketService;

  StreamSubscription? _webSocketSubscription;
  Timer? _autoSyncTimer;
  bool _autoSyncEnabled = true;
  bool _syncOnWiFiOnly = false;

  SyncBloc({
    required SyncService syncService,
    required StravaIntegrationService stravaService,
    required WebSocketService webSocketService,
  })  : _syncService = syncService,
        _stravaService = stravaService,
        _webSocketService = webSocketService,
        super(const SyncInitial()) {
    on<SyncSessionEvent>(_onSyncSession);
    on<SyncAllQueuedEvent>(_onSyncAllQueued);
    on<CheckSyncStatusEvent>(_onCheckSyncStatus);
    on<UploadToStravaEvent>(_onUploadToStrava);
    on<GetSyncQueueStatusEvent>(_onGetSyncQueueStatus);
    on<StopSyncEvent>(_onStopSync);
  }

  /// Handle single session sync
  Future<void> _onSyncSession(
    SyncSessionEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      AppLogger.info('Syncing session: ${event.sessionId}', tag: _tag);

      emit(SyncInProgress(
          synced: 0, total: 1, currentSessionId: event.sessionId));

      final success = await _syncService.uploadWithRetry(event.sessionId);

      if (success) {
        emit(SyncSuccess(event.sessionId));
        AppLogger.info('Session sync successful: ${event.sessionId}',
            tag: _tag);
      } else {
        emit(SyncError('Failed to sync session', sessionId: event.sessionId));
        AppLogger.error('Session sync failed: ${event.sessionId}', tag: _tag);
      }
    } catch (e) {
      AppLogger.error(
        'Error syncing session',
        tag: _tag,
        exception: e,
      );
      emit(SyncError('Error syncing session: $e', sessionId: event.sessionId));
    }
  }

  /// Handle sync all queued sessions
  Future<void> _onSyncAllQueued(
    SyncAllQueuedEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      AppLogger.info('Syncing all queued sessions', tag: _tag);

      final queue = await _syncService.getSyncQueue();

      if (queue.isEmpty) {
        AppLogger.info('No sessions to sync', tag: _tag);
        emit(SyncCompleted(syncedCount: 0, failedCount: 0));
        return;
      }

      emit(SyncInProgress(synced: 0, total: queue.length));

      int synced = 0;
      int failed = 0;

      for (final queueItem in queue) {
        try {
          emit(SyncInProgress(
            synced: synced,
            total: queue.length,
            currentSessionId: queueItem.sessionId,
          ));

          final success =
              await _syncService.uploadWithRetry(queueItem.sessionId);

          if (success) {
            synced++;
            AppLogger.debug(
              'Synced session: ${queueItem.sessionId}',
              tag: _tag,
            );
          } else {
            failed++;
            AppLogger.warning(
              'Failed to sync session: ${queueItem.sessionId}',
              tag: _tag,
            );
          }
        } catch (e) {
          failed++;
          AppLogger.error(
            'Error syncing queue item',
            tag: _tag,
            exception: e,
          );
        }
      }

      emit(SyncCompleted(
        syncedCount: synced,
        failedCount: failed,
        lastSyncTime: DateTime.now(),
      ));

      AppLogger.info(
        'Sync complete: $synced synced, $failed failed',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.error(
        'Error syncing all queued',
        tag: _tag,
        exception: e,
      );
      emit(SyncError('Error syncing all queued: $e'));
    }
  }

  /// Handle check sync status
  Future<void> _onCheckSyncStatus(
    CheckSyncStatusEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final status = await _syncService.checkSyncStatus(event.sessionId);

      if (status == null) {
        emit(SyncError('Session not found', sessionId: event.sessionId));
      } else {
        emit(SyncWaiting(queuePosition: 0, currentSessionId: event.sessionId));
      }
    } catch (e) {
      AppLogger.error(
        'Error checking sync status',
        tag: _tag,
        exception: e,
      );
      emit(SyncError('Error checking status: $e', sessionId: event.sessionId));
    }
  }

  /// Handle upload to Strava
  Future<void> _onUploadToStrava(
    UploadToStravaEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      AppLogger.info('Uploading to Strava: ${event.sessionId}', tag: _tag);

      if (!_stravaService.isAuthenticated) {
        emit(SyncError(
          'Not authenticated with Strava',
          sessionId: event.sessionId,
        ));
        return;
      }

      // TODO: Get session from database and upload
      AppLogger.info('Strava upload initiated for ${event.sessionId}',
          tag: _tag);
      emit(SyncSuccess(event.sessionId));
    } catch (e) {
      AppLogger.error(
        'Error uploading to Strava',
        tag: _tag,
        exception: e,
      );
      emit(SyncError('Error uploading to Strava: $e',
          sessionId: event.sessionId));
    }
  }

  /// Handle get sync queue status
  Future<void> _onGetSyncQueueStatus(
    GetSyncQueueStatusEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final queue = await _syncService.getSyncQueue();
      emit(SyncQueueStatus(pendingCount: queue.length));
    } catch (e) {
      AppLogger.error(
        'Error getting sync queue status',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Handle stop sync
  Future<void> _onStopSync(
    StopSyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    try {
      AppLogger.info('Stopping sync', tag: _tag);
      _stopAutoSync();
      emit(const SyncInitial());
    } catch (e) {
      AppLogger.error(
        'Error stopping sync',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Enable or disable auto sync
  void setAutoSyncEnabled(bool enabled) {
    _autoSyncEnabled = enabled;
    AppLogger.debug('Auto sync enabled: $enabled', tag: _tag);

    if (enabled) {
      _startAutoSync();
    } else {
      _stopAutoSync();
    }
  }

  /// Set WiFi-only sync mode
  void setSyncOnWiFiOnly(bool wifiOnly) {
    _syncOnWiFiOnly = wifiOnly;
    AppLogger.debug('Sync on WiFi only: $wifiOnly', tag: _tag);
  }

  /// Start auto sync timer
  void _startAutoSync() {
    if (_autoSyncTimer != null) return;

    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) {
        if (_autoSyncEnabled) {
          add(const SyncAllQueuedEvent());
        }
      },
    );

    AppLogger.debug('Auto sync started', tag: _tag);
  }

  /// Stop auto sync timer
  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    AppLogger.debug('Auto sync stopped', tag: _tag);
  }

  /// Initialize WebSocket connection for real-time sync
  Future<void> initializeWebSocket() async {
    try {
      AppLogger.info('Initializing WebSocket', tag: _tag);

      await _webSocketService.connect();

      _webSocketSubscription = _webSocketService.onMessage.listen(
        _handleWebSocketMessage,
        onError: (error) {
          AppLogger.error(
            'WebSocket error',
            tag: _tag,
            exception: error,
          );
        },
      );

      AppLogger.info('WebSocket initialized', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error initializing WebSocket',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Handle WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String?;

      switch (type) {
        case 'sync_complete':
          final sessionId = message['sessionId'] as String?;
          if (sessionId != null) {
            add(SyncSessionEvent(sessionId));
          }
          break;
        case 'sync_required':
          add(const SyncAllQueuedEvent());
          break;
        default:
          AppLogger.debug('Unhandled WebSocket message type: $type', tag: _tag);
      }
    } catch (e) {
      AppLogger.error(
        'Error handling WebSocket message',
        tag: _tag,
        exception: e,
      );
    }
  }

  @override
  Future<void> close() async {
    try {
      _stopAutoSync();
      _webSocketSubscription?.cancel();
      await _webSocketService.close();
      AppLogger.info('SyncBloc closed', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error closing SyncBloc',
        tag: _tag,
        exception: e,
      );
    }
    return super.close();
  }
}
