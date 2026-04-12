import 'package:get_it/get_it.dart';
import '../presentation/bloc/bloc.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // BLoCs
    getIt.registerSingleton<SessionBloc>(SessionBloc());
    getIt.registerSingleton<SettingsBloc>(SettingsBloc());

    // TODO: Agregar más BLoCs según sea necesario
    // getIt.registerSingleton<BluetoothBloc>(BluetoothBloc());
    // getIt.registerSingleton<GpsBloc>(GpsBloc());

    // Repositories
    // TODO: Registrar repositories cuando estén implementados
    // getIt.registerSingleton<SessionRepository>(SessionRepositoryImpl());
    // getIt.registerSingleton<SettingsRepository>(SettingsRepositoryImpl());

    // Use Cases (Opcional - depende de la arquitectura elegida)
    // TODO: Registrar use cases si se implementa Clean Architecture

    // Services
    // TODO: Registrar servicios
    // getIt.registerSingleton<DatabaseService>(DatabaseService());
    // getIt.registerSingleton<LocationService>(LocationService());
    // getIt.registerSingleton<BluetoothService>(BluetoothService());
  }

  static void reset() {
    getIt.reset();
  }
}
