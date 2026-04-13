part of 'heart_rate_bloc.dart';

abstract class HeartRateEvent extends Equatable {
  const HeartRateEvent();

  @override
  List<Object?> get props => [];
}

/// Evento cuando se actualiza la FC
class HeartRateUpdatedEvent extends HeartRateEvent {
  final int bpm;

  const HeartRateUpdatedEvent(this.bpm);

  @override
  List<Object?> get props => [bpm];
}

/// Evento cuando se alcanza un umbral de zona
class HeartRateThresholdReachedEvent extends HeartRateEvent {
  final String zone;

  const HeartRateThresholdReachedEvent(this.zone);

  @override
  List<Object?> get props => [zone];
}

/// Evento para iniciar monitoreo
class StartHeartRateMonitoringEvent extends HeartRateEvent {
  const StartHeartRateMonitoringEvent();
}

/// Evento para detener monitoreo
class StopHeartRateMonitoringEvent extends HeartRateEvent {
  const StopHeartRateMonitoringEvent();
}

/// Evento para error en monitoreo de FC
class HeartRateErrorEvent extends HeartRateEvent {
  final String message;

  const HeartRateErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
