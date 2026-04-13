part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class StartSessionEvent extends SessionEvent {
  final String sportType;
  final String? boatType;

  const StartSessionEvent({
    required this.sportType,
    this.boatType,
  });

  @override
  List<Object?> get props => [sportType, boatType];
}

class StopSessionEvent extends SessionEvent {
  const StopSessionEvent();
}

class PauseSessionEvent extends SessionEvent {
  const PauseSessionEvent();
}

class ResumeSessionEvent extends SessionEvent {
  const ResumeSessionEvent();
}

class AddGpsPointEvent extends SessionEvent {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;

  const AddGpsPointEvent({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude, speed];
}

class UpdateMeasurementEvent extends SessionEvent {
  final String type;
  final double value;
  final String unit;

  const UpdateMeasurementEvent({
    required this.type,
    required this.value,
    required this.unit,
  });

  @override
  List<Object?> get props => [type, value, unit];
}

class LoadSessionEvent extends SessionEvent {
  final String sessionId;

  const LoadSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class RequestSessionSyncEvent extends SessionEvent {
  const RequestSessionSyncEvent();
}
