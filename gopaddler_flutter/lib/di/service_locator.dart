import 'package:get_it/get_it.dart';
import '../presentation/bloc/bloc.dart';
import '../data/services/database_service.dart';
import '../data/services/location_service.dart';
import '../data/services/bluetooth_service.dart';
import '../data/services/sensor_service.dart';
import '../data/services/sync_service.dart';
import '../data/services/strava_service.dart';
import '../data/services/websocket_service.dart';
import '../data/repositories/session_repository.dart';
import '../config/environment_config.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Services
    getIt.registerSingleton<DatabaseService>(DatabaseService());
    getIt.registerSingleton<LocationService>(LocationService());
    getIt.registerSingleton<BluetoothService>(BluetoothService());
    getIt.registerSingleton<SensorService>(SensorService());

    // Sync Services
    getIt.registerSingleton<SyncService>(
      SyncService(getIt<DatabaseService>()),
    );

    final stravaService = StravaIntegrationService(
      clientId: EnvironmentConfig.current.stravaClientId,
      clientSecret: EnvironmentConfig.current.stravaClientSecret,
    );
    await stravaService.init();
    getIt.registerSingleton<StravaIntegrationService>(stravaService);

    getIt.registerSingleton<WebSocketService>(WebSocketService());

    // Repositories
    getIt.registerSingleton<SessionRepository>(
      SessionRepositoryImpl(getIt<DatabaseService>()),
    );

    // BLoCs
    getIt.registerSingleton<SessionBloc>(
      SessionBloc(syncService: getIt<SyncService>()),
    );
    getIt.registerSingleton<SettingsBloc>(SettingsBloc());
    getIt.registerSingleton<HeartRateBloc>(HeartRateBloc());
    getIt.registerSingleton<BluetoothBloc>(
      BluetoothBloc(bluetoothService: getIt<BluetoothService>()),
    );
    getIt.registerSingleton<GpsBloc>(
      GpsBloc(
        locationService: getIt<LocationService>(),
        heartRateBloc: getIt<HeartRateBloc>(),
      ),
    );

    // SyncBloc
    getIt.registerSingleton<SyncBloc>(
      SyncBloc(
        syncService: getIt<SyncService>(),
        stravaService: getIt<StravaIntegrationService>(),
        webSocketService: getIt<WebSocketService>(),
      ),
    );
  }

  static void reset() {
    getIt.reset();
  }
}
