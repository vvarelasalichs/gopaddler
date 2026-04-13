part of 'gps_bloc.dart';

abstract class GpsState extends Equatable {
  const GpsState();

  @override
  List<Object?> get props => [];
}

class GpsInitial extends GpsState {
  const GpsInitial();
}

class GpsPermissionsRequesting extends GpsState {
  const GpsPermissionsRequesting();
}

class GpsPermissionsDenied extends GpsState {
  final String reason;

  const GpsPermissionsDenied(this.reason);

  @override
  List<Object?> get props => [reason];
}

class GpsPermissionsGranted extends GpsState {
  const GpsPermissionsGranted();
}

class GpsTracking extends GpsState {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double accuracy;
  final double totalDistance;
  final double averageSpeed;
  final int pointCount;

  const GpsTracking({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.totalDistance,
    required this.averageSpeed,
    required this.pointCount,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        altitude,
        speed,
        accuracy,
        totalDistance,
        averageSpeed,
        pointCount,
      ];

  GpsTracking copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? accuracy,
    double? totalDistance,
    double? averageSpeed,
    int? pointCount,
  }) {
    return GpsTracking(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      totalDistance: totalDistance ?? this.totalDistance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      pointCount: pointCount ?? this.pointCount,
    );
  }
}

class GpsStopped extends GpsState {
  final int pointCount;
  final double totalDistance;
  final double averageSpeed;

  const GpsStopped({
    required this.pointCount,
    required this.totalDistance,
    required this.averageSpeed,
  });

  @override
  List<Object?> get props => [pointCount, totalDistance, averageSpeed];
}

class GpsError extends GpsState {
  final String message;

  const GpsError(this.message);

  @override
  List<Object?> get props => [message];
}
