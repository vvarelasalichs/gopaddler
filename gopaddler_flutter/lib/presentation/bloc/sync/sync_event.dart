part of 'sync_bloc.dart';

/// Base class for all sync events
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sync a specific session
class SyncSessionEvent extends SyncEvent {
  final String sessionId;

  const SyncSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to sync all queued sessions
class SyncAllQueuedEvent extends SyncEvent {
  const SyncAllQueuedEvent();
}

/// Event to check sync status of a session
class CheckSyncStatusEvent extends SyncEvent {
  final String sessionId;

  const CheckSyncStatusEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to report sync progress
class SyncProgressEvent extends SyncEvent {
  final int synced;
  final int total;
  final String? currentSessionId;

  const SyncProgressEvent({
    required this.synced,
    required this.total,
    this.currentSessionId,
  });

  @override
  List<Object?> get props => [synced, total, currentSessionId];
}

/// Event to report sync error
class SyncErrorEvent extends SyncEvent {
  final String message;
  final String? sessionId;

  const SyncErrorEvent(this.message, {this.sessionId});

  @override
  List<Object?> get props => [message, sessionId];
}

/// Event to report successful sync
class SyncSuccessEvent extends SyncEvent {
  final String sessionId;
  final Map<String, dynamic>? metadata;

  const SyncSuccessEvent(this.sessionId, {this.metadata});

  @override
  List<Object?> get props => [sessionId, metadata];
}

/// Event to upload session to Strava
class UploadToStravaEvent extends SyncEvent {
  final String sessionId;

  const UploadToStravaEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to sync queue position
class GetSyncQueueStatusEvent extends SyncEvent {
  const GetSyncQueueStatusEvent();
}

/// Event to stop ongoing sync
class StopSyncEvent extends SyncEvent {
  const StopSyncEvent();
}
