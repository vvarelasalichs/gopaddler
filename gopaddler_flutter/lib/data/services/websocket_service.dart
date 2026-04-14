import 'dart:async';
import '../../utils/app_logger.dart';

/// Service for WebSocket real-time communication (MVP: Disabled)
/// 
/// In MVP mode, this service is disabled and doesn't attempt server connections.
/// WebSocket support requires:
/// - Backend server with WebSocket endpoint
/// - Real-time sync infrastructure
/// - Proper authentication tokens
/// 
/// This can be re-enabled when backend is ready.
class WebSocketService {
  static const String _tag = 'WebSocketService';

  StreamController<Map<String, dynamic>>? _messageController;
  bool _isConnecting = false;
  bool _isConnected = false;

  /// MVP: NO-OP WebSocket URL (no server connection)
  String _getWebSocketUrl() {
    AppLogger.debug('MVP MODE: WebSocket URL generation disabled', tag: _tag);
    return 'ws://localhost:8000/ws';
  }

  /// Connect to WebSocket server (MVP: Disabled)
  Future<void> connect() async {
    if (_isConnecting) {
      AppLogger.debug('MVP MODE: Connection skipped (already in progress)',
          tag: _tag);
      return;
    }

    if (isConnected) {
      AppLogger.debug('MVP MODE: Already in connected state (local)', tag: _tag);
      return;
    }

    try {
      _isConnecting = true;
      AppLogger.info(
        'MVP MODE: WebSocket connection disabled. '
        'Enable when backend server is available.',
        tag: _tag,
      );

      // Initialize message controller for compatibility
      _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
      _isConnected = false;
      _isConnecting = false;
    } catch (e) {
      AppLogger.error(
        'Error in MVP connect',
        tag: _tag,
        exception: e,
      );
      _isConnecting = false;
    }
  }

  /// Disconnect from WebSocket (MVP: NO-OP)
  Future<void> disconnect() async {
    try {
      AppLogger.info('MVP MODE: WebSocket disconnect (no-op)', tag: _tag);
      _isConnected = false;

      if (_messageController != null && !_messageController!.isClosed) {
        await _messageController!.close();
      }
      _messageController = null;
    } catch (e) {
      AppLogger.error(
        'Error in MVP disconnect',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Send message through WebSocket (MVP: NO-OP)
  void send(Map<String, dynamic> message) {
    try {
      if (!isConnected) {
        AppLogger.debug(
          'MVP MODE: Message not sent (not connected)',
          tag: _tag,
        );
        return;
      }

      AppLogger.debug(
        'MVP MODE: Message send skipped (no server)',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.error(
        'Error in MVP send',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Get stream of received messages (MVP: Empty stream)
  Stream<Map<String, dynamic>> get onMessage {
    if (_messageController == null) {
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _messageController!.stream;
  }

  /// Check if connected (MVP: Always false)
  bool get isConnected => _isConnected;

  /// Reconnect with exponential backoff (MVP: NO-OP)
  Future<void> reconnect() async {
    try {
      AppLogger.debug('MVP MODE: Reconnect skipped (no server)', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error in MVP reconnect',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Close and cleanup resources
  Future<void> close() async {
    try {
      await disconnect();
      _messageController = null;
    } catch (e) {
      AppLogger.error(
        'Error closing WebSocket service',
        tag: _tag,
        exception: e,
      );
    }
  }
}
