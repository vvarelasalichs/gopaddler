import 'package:get_it/get_it.dart';
import '../presentation/bloc/bloc.dart';
import '../data/services/database_service.dart';
import '../data/repositories/session_repository.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Services
    getIt.registerSingleton<DatabaseService>(DatabaseService());

    // Repositories
    getIt.registerSingleton<SessionRepository>(
      SessionRepositoryImpl(getIt<DatabaseService>()),
    );

    // BLoCs
    getIt.registerSingleton<SessionBloc>(SessionBloc());
    getIt.registerSingleton<SettingsBloc>(SettingsBloc());

    // TODO: Agregar más BLoCs según sea necesario
    // getIt.registerSingleton<BluetoothBloc>(BluetoothBloc());
    // getIt.registerSingleton<GpsBloc>(GpsBloc());
    // getIt.registerSingleton<LocationService>(LocationService());
    // getIt.registerSingleton<BluetoothService>(BluetoothService());
  }

  static void reset() {
    getIt.reset();
  }
}
