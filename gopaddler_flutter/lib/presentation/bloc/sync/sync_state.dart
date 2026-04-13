part of 'sync_bloc.dart';

/// Base class for all sync states
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Sync in progress
class SyncInProgress extends SyncState {
  final int synced;
  final int total;
  final String? currentSessionId;

  const SyncInProgress({
    required this.synced,
    required this.total,
    this.currentSessionId,
  });

  @override
  List<Object?> get props => [synced, total, currentSessionId];

  SyncInProgress copyWith({
    int? synced,
    int? total,
    String? currentSessionId,
  }) {
    return SyncInProgress(
      synced: synced ?? this.synced,
      total: total ?? this.total,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

/// Sync completed
class SyncCompleted extends SyncState {
  final int syncedCount;
  final int failedCount;
  final DateTime? lastSyncTime;

  const SyncCompleted({
    required this.syncedCount,
    required this.failedCount,
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [syncedCount, failedCount, lastSyncTime];

  SyncCompleted copyWith({
    int? syncedCount,
    int? failedCount,
    DateTime? lastSyncTime,
  }) {
    return SyncCompleted(
      syncedCount: syncedCount ?? this.syncedCount,
      failedCount: failedCount ?? this.failedCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Sync error
class SyncError extends SyncState {
  final String message;
  final String? sessionId;

  const SyncError(this.message, {this.sessionId});

  @override
  List<Object?> get props => [message, sessionId];

  SyncError copyWith({
    String? message,
    String? sessionId,
  }) {
    return SyncError(
      message ?? this.message,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

/// Sync queue status
class SyncQueueStatus extends SyncState {
  final int pendingCount;
  final DateTime? lastSync;
  final DateTime? nextScheduledSync;

  const SyncQueueStatus({
    required this.pendingCount,
    this.lastSync,
    this.nextScheduledSync,
  });

  @override
  List<Object?> get props => [pendingCount, lastSync, nextScheduledSync];

  SyncQueueStatus copyWith({
    int? pendingCount,
    DateTime? lastSync,
    DateTime? nextScheduledSync,
  }) {
    return SyncQueueStatus(
      pendingCount: pendingCount ?? this.pendingCount,
      lastSync: lastSync ?? this.lastSync,
      nextScheduledSync: nextScheduledSync ?? this.nextScheduledSync,
    );
  }
}

/// Single session sync success
class SyncSuccess extends SyncState {
  final String sessionId;
  final Map<String, dynamic>? metadata;

  const SyncSuccess(this.sessionId, {this.metadata});

  @override
  List<Object?> get props => [sessionId, metadata];
}

/// Waiting for sync
class SyncWaiting extends SyncState {
  final int queuePosition;
  final String? currentSessionId;

  const SyncWaiting({
    required this.queuePosition,
    this.currentSessionId,
  });

  @override
  List<Object?> get props => [queuePosition, currentSessionId];

  SyncWaiting copyWith({
    int? queuePosition,
    String? currentSessionId,
  }) {
    return SyncWaiting(
      queuePosition: queuePosition ?? this.queuePosition,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}
