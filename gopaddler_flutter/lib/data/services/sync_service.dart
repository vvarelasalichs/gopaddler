import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../models/sync_queue.dart';
import '../models/session.dart';
import '../../config/environment_config.dart';
import '../../utils/app_logger.dart';
import 'database_service.dart';

/// Service for synchronizing sessions to the server
class SyncService {
  final DatabaseService _database;
  static const String _tag = 'SyncService';
  static const int _maxRetries = 5;
  static const int _baseDelaySeconds = 1;

  SyncService(this._database);

  /// Upload a session to the server
  Future<bool> uploadSession(String sessionId) async {
    try {
      AppLogger.info('Uploading session: $sessionId', tag: _tag);

      final session = await _database.getSession(sessionId);
      if (session == null) {
        AppLogger.error('Session not found: $sessionId', tag: _tag);
        return false;
      }

      final url = Uri.parse(
          '${EnvironmentConfig.current.apiBaseUrl}/sessions/$sessionId');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${EnvironmentConfig.current.apiKey}',
            },
            body: jsonEncode(session.toMap()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Upload request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Session uploaded successfully: $sessionId', tag: _tag);

        // Update session as synced
        session.isSynced = true;
        await _database.updateSession(session);

        // Remove from sync queue
        await _database.removeSyncQueue(sessionId);

        return true;
      } else {
        AppLogger.error(
          'Upload failed with status ${response.statusCode}: ${response.body}',
          tag: _tag,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error(
        'Error uploading session',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Download sessions from the server
  Future<List<Session>> downloadSessions() async {
    try {
      AppLogger.info('Downloading sessions from server', tag: _tag);

      final url = Uri.parse('${EnvironmentConfig.current.apiBaseUrl}/sessions');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.current.apiKey}',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Download request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final sessions = data
            .map((json) => Session.fromMap(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Downloaded ${sessions.length} sessions', tag: _tag);
        return sessions;
      } else {
        AppLogger.error(
          'Download failed with status ${response.statusCode}',
          tag: _tag,
        );
        return [];
      }
    } catch (e) {
      AppLogger.error(
        'Error downloading sessions',
        tag: _tag,
        exception: e,
      );
      return [];
    }
  }

  /// Queue a session for synchronization
  Future<void> queueSessionForSync(String sessionId) async {
    try {
      AppLogger.info('Queueing session for sync: $sessionId', tag: _tag);
      await _database.insertSyncQueue(sessionId);
    } catch (e) {
      AppLogger.error(
        'Error queueing session',
        tag: _tag,
        exception: e,
      );
      rethrow;
    }
  }

  /// Get all pending sync queue items
  Future<List<SyncQueue>> getSyncQueue() async {
    try {
      final queue = await _database.getSyncQueue();
      AppLogger.debug('Retrieved ${queue.length} sync queue items', tag: _tag);
      return queue;
    } catch (e) {
      AppLogger.error(
        'Error getting sync queue',
        tag: _tag,
        exception: e,
      );
      rethrow;
    }
  }

  /// Remove a session from the sync queue
  Future<void> clearSyncQueue(String sessionId) async {
    try {
      AppLogger.info('Removing from sync queue: $sessionId', tag: _tag);
      await _database.removeSyncQueue(sessionId);
    } catch (e) {
      AppLogger.error(
        'Error clearing sync queue',
        tag: _tag,
        exception: e,
      );
      rethrow;
    }
  }

  /// Check sync status of a session
  Future<SyncStatus?> checkSyncStatus(String sessionId) async {
    try {
      final queueItem = await _database.getSyncQueueItem(sessionId);
      if (queueItem == null) {
        // Check if already synced
        final session = await _database.getSession(sessionId);
        if (session?.isSynced ?? false) {
          return SyncStatus.completed;
        }
        return null;
      }
      return queueItem.status;
    } catch (e) {
      AppLogger.error(
        'Error checking sync status',
        tag: _tag,
        exception: e,
      );
      rethrow;
    }
  }

  /// Upload a session with automatic retry logic
  Future<bool> uploadWithRetry(String sessionId,
      {int maxRetries = _maxRetries}) async {
    try {
      AppLogger.info(
        'Starting upload with retry for session: $sessionId',
        tag: _tag,
      );

      bool success = false;
      int attempt = 0;

      while (attempt < maxRetries && !success) {
        try {
          success = await uploadSession(sessionId);

          if (success) {
            AppLogger.info(
              'Upload successful for session: $sessionId',
              tag: _tag,
            );
            await _database.updateSyncStatus(
              sessionId,
              SyncStatus.completed,
              null,
            );
            return true;
          }

          attempt++;

          if (attempt < maxRetries) {
            // Calculate exponential backoff: 1s * 2^attempt
            final delaySeconds = _baseDelaySeconds * (1 << attempt);
            AppLogger.info(
              'Retry attempt $attempt for session $sessionId, '
              'waiting ${delaySeconds}s',
              tag: _tag,
            );

            await Future.delayed(Duration(seconds: delaySeconds));
          }
        } catch (e) {
          AppLogger.error(
            'Error during upload attempt $attempt',
            tag: _tag,
            exception: e,
          );

          attempt++;

          if (attempt < maxRetries) {
            final delaySeconds = _baseDelaySeconds * (1 << attempt);
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }

      if (!success) {
        AppLogger.error(
          'Upload failed after $maxRetries retries for session: $sessionId',
          tag: _tag,
        );
        await _database.updateSyncStatus(
          sessionId,
          SyncStatus.failed,
          'Max retries exceeded',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'Error in uploadWithRetry',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }
}
