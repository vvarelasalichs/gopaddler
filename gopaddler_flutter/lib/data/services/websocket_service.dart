import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../config/environment_config.dart';
import '../../utils/app_logger.dart';

/// Service for WebSocket real-time communication with the server
class WebSocketService {
  static const String _tag = 'WebSocketService';
  static const int _heartbeatIntervalSeconds = 30;
  static const int _maxReconnectDelaySeconds = 30;
  static const int _baseReconnectDelaySeconds = 1;

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  int _reconnectAttempt = 0;
  bool _isConnecting = false;

  /// Get WebSocket URL from environment config
  String _getWebSocketUrl() {
    final apiUrl = EnvironmentConfig.current.apiBaseUrl;
    final wsUrl = apiUrl.replaceFirst('http', 'ws');
    return '$wsUrl/ws';
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnecting) {
      AppLogger.debug('Connection already in progress', tag: _tag);
      return;
    }

    if (isConnected) {
      AppLogger.debug('Already connected', tag: _tag);
      return;
    }

    try {
      _isConnecting = true;
      final wsUrl = _getWebSocketUrl();
      AppLogger.info('Connecting to WebSocket: $wsUrl', tag: _tag);

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Initialize message controller
      _messageController = StreamController<Map<String, dynamic>>.broadcast();

      // Listen to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _resetReconnectBackoff();
      _startHeartbeat();

      AppLogger.info('WebSocket connected successfully', tag: _tag);
      _isConnecting = false;
    } catch (e) {
      AppLogger.error(
        'Error connecting to WebSocket',
        tag: _tag,
        exception: e,
      );
      _isConnecting = false;
      await Future.delayed(Duration(seconds: _calculateReconnectDelay()));
      await reconnect();
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    try {
      AppLogger.info('Disconnecting from WebSocket', tag: _tag);

      _stopHeartbeat();
      _stopReconnectTimer();

      if (_channel != null) {
        await _channel!.sink.close(status.goingAway);
      }

      _channel = null;

      if (!_messageController!.isClosed) {
        await _messageController!.close();
      }
      _messageController = null;

      AppLogger.info('WebSocket disconnected', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error disconnecting from WebSocket',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Send message through WebSocket
  void send(Map<String, dynamic> message) {
    try {
      if (!isConnected) {
        AppLogger.warning('WebSocket not connected, cannot send message',
            tag: _tag);
        return;
      }

      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      AppLogger.debug('Message sent: ${message['type'] ?? 'unknown'}',
          tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error sending message',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Get stream of received messages
  Stream<Map<String, dynamic>> get onMessage {
    if (_messageController == null) {
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _messageController!.stream;
  }

  /// Check if connected
  bool get isConnected => _channel != null && !_isConnecting;

  /// Reconnect with exponential backoff
  Future<void> reconnect() async {
    try {
      final delay = _calculateReconnectDelay();
      AppLogger.info(
        'Reconnecting in ${delay}s (attempt '
        '${_reconnectAttempt + 1})',
        tag: _tag,
      );

      _reconnectTimer = Timer(Duration(seconds: delay), () async {
        _reconnectAttempt++;
        await connect();
      });
    } catch (e) {
      AppLogger.error(
        'Error during reconnect',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Message handler
  void _onMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message) as Map<String, dynamic>;
        _messageController?.add(data);
        AppLogger.debug('Message received: ${data['type'] ?? 'unknown'}',
            tag: _tag);
      }
    } catch (e) {
      AppLogger.error(
        'Error processing message',
        tag: _tag,
        exception: e,
      );
    }
  }

  /// Error handler
  void _onError(dynamic error) {
    AppLogger.error(
      'WebSocket error',
      tag: _tag,
      exception: error,
    );
  }

  /// Connection closed handler
  void _onDone() {
    AppLogger.warning('WebSocket connection closed', tag: _tag);
    _stopHeartbeat();
    reconnect();
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatIntervalSeconds),
      (_) {
        if (isConnected) {
          send({
            'type': 'heartbeat',
            'timestamp': DateTime.now().toIso8601String()
          });
        }
      },
    );
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Calculate reconnect delay with exponential backoff
  int _calculateReconnectDelay() {
    if (_reconnectAttempt == 0) {
      return _baseReconnectDelaySeconds;
    }

    // Exponential backoff: 1s, 2s, 4s, 8s, ..., max 30s
    final delay = _baseReconnectDelaySeconds * (1 << (_reconnectAttempt - 1));
    return delay > _maxReconnectDelaySeconds
        ? _maxReconnectDelaySeconds
        : delay;
  }

  /// Reset reconnect backoff counter
  void _resetReconnectBackoff() {
    _reconnectAttempt = 0;
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
