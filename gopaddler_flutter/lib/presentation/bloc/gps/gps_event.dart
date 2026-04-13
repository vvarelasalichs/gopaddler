part of 'gps_bloc.dart';

abstract class GpsEvent extends Equatable {
  const GpsEvent();

  @override
  List<Object?> get props => [];
}

class RequestGpsPermissionsEvent extends GpsEvent {
  const RequestGpsPermissionsEvent();
}

class StartGpsTrackingEvent extends GpsEvent {
  final int intervalSeconds;

  const StartGpsTrackingEvent({this.intervalSeconds = 5});

  @override
  List<Object?> get props => [intervalSeconds];
}

class StopGpsTrackingEvent extends GpsEvent {
  const StopGpsTrackingEvent();
}

class GpsLocationReceivedEvent extends GpsEvent {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double accuracy;

  const GpsLocationReceivedEvent({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude, speed, accuracy];
}

class GpsErrorEvent extends GpsEvent {
  final String message;

  const GpsErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
