import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  AppSettings _settings = const AppSettings();

  SettingsBloc() : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateGpsRateEvent>(_onUpdateGpsRate);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UpdateAutoSyncEvent>(_onUpdateAutoSync);
    on<UpdateSyncOnWiFiOnlyEvent>(_onUpdateSyncOnWiFiOnly);
    on<UpdateSportTypeEvent>(_onUpdateSportType);
    on<UpdateBoatTypeEvent>(_onUpdateBoatType);
    on<UpdateUnitsEvent>(_onUpdateUnits);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());
      // TODO: Cargar desde SharedPreferences o base de datos
      emit(SettingsLoaded(_settings));
    } catch (e) {
      emit(SettingsError('Error loading settings: $e'));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(languageCode: event.languageCode);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating language: $e'));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(darkMode: event.darkMode);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating theme: $e'));
    }
  }

  Future<void> _onUpdateGpsRate(
    UpdateGpsRateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(gpsIntervalSeconds: event.intervalSeconds);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating GPS rate: $e'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(
        userName: event.name,
        userEmail: event.email,
      );
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating profile: $e'));
    }
  }

  Future<void> _onUpdateAutoSync(
    UpdateAutoSyncEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(autoSync: event.enabled);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating auto sync: $e'));
    }
  }

  Future<void> _onUpdateSyncOnWiFiOnly(
    UpdateSyncOnWiFiOnlyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(syncOnWiFiOnly: event.wifiOnly);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating sync WiFi setting: $e'));
    }
  }

  Future<void> _onUpdateSportType(
    UpdateSportTypeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(sportType: event.sportType);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating sport type: $e'));
    }
  }

  Future<void> _onUpdateBoatType(
    UpdateBoatTypeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(boatType: event.boatType);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating boat type: $e'));
    }
  }

  Future<void> _onUpdateUnits(
    UpdateUnitsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      _settings = _settings.copyWith(preferredUnit: event.unit);
      // TODO: Persistir cambios
      emit(SettingsUpdated(_settings));
    } catch (e) {
      emit(SettingsError('Error updating units: $e'));
    }
  }
}
