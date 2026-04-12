/// Application Configuration for different environments
class AppConfig {
  static const String appName = 'GoPaddler';
  static const String appVersion = '1.8.0';
  static const String packageName = 'com.gopaddler.app';
  
  // Session configuration
  static const String databaseName = 'sessions.db';
  static const int apiVersion = 2;
  static const int sessionVersion = 5;
  static const int distanceStep = 10; // meters
  
  // GPS Configuration
  static const int defaultGpsUpdateRateSeconds = 5;
  static const double gpsAccuracyThreshold = 10.0; // meters
  
  // Heart Rate Configuration
  static const int hrMinBpm = 30;
  static const int hrMaxBpm = 220;
  
  // Bluetooth Configuration
  static const Duration bleScanTimeout = Duration(seconds: 10);
  static const Duration bleConnectionTimeout = Duration(seconds: 30);
  
  // API Endpoints
  static const Map<String, ApiEndpoint> endpoints = {
    'dev': ApiEndpoint(
      server: 'http://local.gopaddler.com',
      websocket: 'ws://local.gopaddler.com/websocket',
    ),
    'remote-dev': ApiEndpoint(
      server: 'https://dev.uttercoach.com',
      websocket: 'wss://dev.uttercoach.com/websocket',
    ),
    'prod': ApiEndpoint(
      server: 'https://app.uttercoach.com',
      websocket: 'wss://app.uttercoach.com/websocket',
    ),
  };
  
  // Supported locales
  static const List<String> supportedLanguages = ['es', 'en', 'pt', 'ca'];
  static const String defaultLanguage = 'es';
  
  // Sport types
  static const List<String> sportTypes = ['canoeing', 'kayaking', 'cycling'];
  static const String defaultSportType = 'canoeing';
}

class ApiEndpoint {
  final String server;
  final String websocket;

  const ApiEndpoint({
    required this.server,
    required this.websocket,
  });
}

/// Get current environment configuration
enum Environment { dev, remoteDev, prod }

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.dev;

  static ApiEndpoint getEndpoint() {
    final endpointKey = currentEnvironment == Environment.dev
        ? 'dev'
        : currentEnvironment == Environment.remoteDev
            ? 'remote-dev'
            : 'prod';
    
    return AppConfig.endpoints[endpointKey] ?? 
           AppConfig.endpoints['dev']!;
  }
}
