enum Environment { development, production, staging }

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String apiKey;
  final String stravaClientId;
  final String stravaClientSecret;
  final bool enableLogging;
  final bool enableCrashlytics;
  final String appName;
  final String appVersion;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.stravaClientId,
    required this.stravaClientSecret,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.appName,
    required this.appVersion,
  });

  factory EnvironmentConfig.development() {
    return const EnvironmentConfig(
      environment: Environment.development,
      apiBaseUrl: 'http://localhost:3000/api',
      apiKey: 'dev-key-12345',
      stravaClientId: 'dev-strava-id',
      stravaClientSecret: 'dev-strava-secret',
      enableLogging: true,
      enableCrashlytics: false,
      appName: 'GoPaddler Dev',
      appVersion: '1.8.0+dev',
    );
  }

  factory EnvironmentConfig.staging() {
    return const EnvironmentConfig(
      environment: Environment.staging,
      apiBaseUrl: 'https://staging-api.uttercoach.com/api',
      apiKey: 'staging-key-12345',
      stravaClientId: 'staging-strava-id',
      stravaClientSecret: 'staging-strava-secret',
      enableLogging: true,
      enableCrashlytics: true,
      appName: 'GoPaddler Staging',
      appVersion: '1.8.0+staging',
    );
  }

  factory EnvironmentConfig.production() {
    return const EnvironmentConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.gopaddler.com/api',
      apiKey: 'prod-key-12345',
      stravaClientId: 'prod-strava-id',
      stravaClientSecret: 'prod-strava-secret',
      enableLogging: false,
      enableCrashlytics: true,
      appName: 'GoPaddler',
      appVersion: '1.8.0',
    );
  }

  static EnvironmentConfig _current = EnvironmentConfig.development();

  static EnvironmentConfig get current => _current;

  /// Establece el ambiente actual (útil para testing)
  static void setEnvironment(EnvironmentConfig config) {
    _current = config;
  }

  /// Factory simplificado para obtener configuración por Environment
  static EnvironmentConfig fromEnvironment(Environment env) {
    return switch (env) {
      Environment.development => EnvironmentConfig.development(),
      Environment.staging => EnvironmentConfig.staging(),
      Environment.production => EnvironmentConfig.production(),
    };
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
