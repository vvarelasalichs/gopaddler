import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/environment_config.dart';
import 'di/service_locator.dart';
import 'presentation/bloc/bloc.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar logger
  AppLogger.init();
  AppLogger.info('Starting GoPaddler application');

  // Configurar ambiente (por defecto desarrollo)
  EnvironmentConfig.setEnvironment(EnvironmentConfig.development());
  AppLogger.debug('Environment: ${EnvironmentConfig.current.environment}');

  // Configurar dependencias
  await ServiceLocator.setup();
  AppLogger.info('Service locator initialized');

  runApp(const GoPaddlerApp());
}

class GoPaddlerApp extends StatelessWidget {
  const GoPaddlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>(
          create: (context) => getIt<SessionBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) =>
              getIt<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<GpsBloc>(
          create: (context) => getIt<GpsBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: EnvironmentConfig.current.appName,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: _getThemeMode(state),
            routerConfig: router,
            debugShowCheckedModeBanner: EnvironmentConfig.current.isDevelopment,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'), // Spanish
              Locale('en', 'US'), // English
              Locale('pt', 'PT'), // Portuguese
              Locale('ca', 'ES'), // Catalan
            ],
            locale: _getLocale(state),
          );
        },
      ),
    );
  }

  static ThemeMode _getThemeMode(SettingsState state) {
    if (state is SettingsLoaded || state is SettingsUpdated) {
      final settings = state is SettingsLoaded
          ? state.settings
          : (state as SettingsUpdated).settings;
      return settings.darkMode ? ThemeMode.dark : ThemeMode.light;
    }
    return ThemeMode.system;
  }

  static Locale? _getLocale(SettingsState state) {
    if (state is SettingsLoaded || state is SettingsUpdated) {
      final settings = state is SettingsLoaded
          ? state.settings
          : (state as SettingsUpdated).settings;
      return Locale(settings.languageCode);
    }
    return null;
  }
}
