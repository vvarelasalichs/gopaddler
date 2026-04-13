part of 'settings_bloc.dart';

class AppSettings extends Equatable {
  final String languageCode;
  final bool darkMode;
  final int gpsIntervalSeconds;
  final String? userName;
  final String? userEmail;
  final bool autoSync;
  final bool syncOnWiFiOnly;

  const AppSettings({
    this.languageCode = 'en',
    this.darkMode = false,
    this.gpsIntervalSeconds = 5,
    this.userName,
    this.userEmail,
    this.autoSync = true,
    this.syncOnWiFiOnly = false,
  });

  AppSettings copyWith({
    String? languageCode,
    bool? darkMode,
    int? gpsIntervalSeconds,
    String? userName,
    String? userEmail,
    bool? autoSync,
    bool? syncOnWiFiOnly,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      darkMode: darkMode ?? this.darkMode,
      gpsIntervalSeconds: gpsIntervalSeconds ?? this.gpsIntervalSeconds,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      autoSync: autoSync ?? this.autoSync,
      syncOnWiFiOnly: syncOnWiFiOnly ?? this.syncOnWiFiOnly,
    );
  }

  @override
  List<Object?> get props => [
        languageCode,
        darkMode,
        gpsIntervalSeconds,
        userName,
        userEmail,
        autoSync,
        syncOnWiFiOnly,
      ];
}

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsUpdated extends SettingsState {
  final AppSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
