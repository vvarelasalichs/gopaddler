/// SyncQueue model for managing session synchronization queue
class SyncQueue {
  final int id;
  final String sessionId;
  final DateTime timestamp;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime? lastSyncAttempt;

  SyncQueue({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.lastError,
    this.lastSyncAttempt,
  });

  /// Convert SyncQueue to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'retryCount': retryCount,
      'lastError': lastError,
      'lastSyncAttempt': lastSyncAttempt?.millisecondsSinceEpoch,
    };
  }

  /// Create SyncQueue from database map
  factory SyncQueue.fromMap(Map<String, dynamic> map) {
    return SyncQueue(
      id: map['id'] as int,
      sessionId: map['sessionId'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: map['retryCount'] as int? ?? 0,
      lastError: map['lastError'] as String?,
      lastSyncAttempt: map['lastSyncAttempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAttempt'] as int)
          : null,
    );
  }

  /// Convert SyncQueue to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'retryCount': retryCount,
      'lastError': lastError,
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
    };
  }

  /// Create SyncQueue from JSON
  factory SyncQueue.fromJson(Map<String, dynamic> json) {
    return SyncQueue(
      id: json['id'] as int? ?? 0,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
      lastSyncAttempt: json['lastSyncAttempt'] != null
          ? DateTime.parse(json['lastSyncAttempt'] as String)
          : null,
    );
  }

  /// Create a copy of SyncQueue with modified fields
  SyncQueue copyWith({
    int? id,
    String? sessionId,
    DateTime? timestamp,
    SyncStatus? status,
    int? retryCount,
    String? lastError,
    DateTime? lastSyncAttempt,
  }) {
    return SyncQueue(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
    );
  }
}

/// Enum for sync status
enum SyncStatus {
  pending,
  syncing,
  completed,
  failed,
  retry,
}
