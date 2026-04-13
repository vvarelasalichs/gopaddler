part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateLanguageEvent extends SettingsEvent {
  final String languageCode;

  const UpdateLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class UpdateThemeEvent extends SettingsEvent {
  final bool darkMode;

  const UpdateThemeEvent(this.darkMode);

  @override
  List<Object?> get props => [darkMode];
}

class UpdateGpsRateEvent extends SettingsEvent {
  final int intervalSeconds;

  const UpdateGpsRateEvent(this.intervalSeconds);

  @override
  List<Object?> get props => [intervalSeconds];
}

class UpdateUserProfileEvent extends SettingsEvent {
  final String name;
  final String email;

  const UpdateUserProfileEvent({
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [name, email];
}

class UpdateAutoSyncEvent extends SettingsEvent {
  final bool enabled;

  const UpdateAutoSyncEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSyncOnWiFiOnlyEvent extends SettingsEvent {
  final bool wifiOnly;

  const UpdateSyncOnWiFiOnlyEvent(this.wifiOnly);

  @override
  List<Object?> get props => [wifiOnly];
}
