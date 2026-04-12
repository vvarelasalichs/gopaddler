/// Session model - Main domain entity for tracking sessions
import 'package:flutter/foundation.dart';

class Session {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final String sportType;
  final String? boatType;
  final List<GpsPoint> gpsPoints;
  final List<Measurement> measurements;
  final List<Split> splits;
  final List<HeartRateZone> zones;
  final SessionSettings settings;
  bool isSynced;
  
  Session({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.sportType,
    this.boatType,
    this.gpsPoints = const [],
    this.measurements = const [],
    this.splits = const [],
    this.zones = const [],
    required this.settings,
    this.isSynced = false,
  });

  // Calculators
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get totalDistance {
    double distance = 0.0;
    for (int i = 0; i < gpsPoints.length - 1; i++) {
      distance += gpsPoints[i].distanceTo(gpsPoints[i + 1]);
    }
    return distance;
  }

  double get averageSpeed {
    if (duration.inSeconds == 0) return 0.0;
    return (totalDistance / 1000) / (duration.inMinutes / 60);
  }

  double get maxSpeed {
    return gpsPoints.fold(0.0, (prev, point) => point.speed > prev ? point.speed : prev);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'sportType': sportType,
      'boatType': boatType,
      'duration': duration.inSeconds,
      'totalDistance': totalDistance,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      sportType: map['sportType'] ?? 'canoeing',
      boatType: map['boatType'],
      settings: SessionSettings(),
    );
  }
}

/// GPS Point with coordinates and timestamp
class GpsPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime timestamp;

  GpsPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  /// Calculate distance to another point (Haversine formula)
  double distanceTo(GpsPoint other) {
    const earthRadius = 6371000; // meters
    final dLat = _toRad(other.latitude - latitude);
    final dLon = _toRad(other.longitude - longitude);
    final a = 
      (_sin(dLat / 2) * _sin(dLat / 2)) +
      _cos(_toRad(latitude)) * _cos(_toRad(other.latitude)) * 
      (_sin(dLon / 2) * _sin(dLon / 2));
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * 3.14159265359 / 180;
  static double _sin(double x) => double.parse(sin(x).toStringAsFixed(10));
  static double _cos(double x) => double.parse(cos(x).toStringAsFixed(10));
  static double _sqrt(double x) => x.sqrt();
  static double _atan2(double y, double x) => atan2(y, x);
}

/// Generic measurement (Speed, Pace, Distance, etc.)
class Measurement {
  final String type; // speed, pace, distance, cadence, strokeRate
  final double value;
  final String unit; // m/s, min/km, m, rpm, strokes/min
  final DateTime timestamp;

  Measurement({
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Session split for interval tracking
class Split {
  final int number;
  final Duration duration;
  final double distance;
  final double averageSpeed;
  final double averagePace;
  final int? averageHeartRate;

  Split({
    required this.number,
    required this.duration,
    required this.distance,
    required this.averageSpeed,
    required this.averagePace,
    this.averageHeartRate,
  });
}

/// Heart rate zone for training zones
class HeartRateZone {
  final String name;
  final int minBpm;
  final int maxBpm;
  final Duration timeInZone;

  HeartRateZone({
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    required this.timeInZone,
  });
}

/// Session settings specific to a session
class SessionSettings {
  final bool useBackgroundGps;
  final bool useHeartRateMonitor;
  final bool useAudioFeedback;
  final bool recordAccelerometer;
  final int gpsUpdateRateSeconds;

  SessionSettings({
    this.useBackgroundGps = true,
    this.useHeartRateMonitor = false,
    this.useAudioFeedback = true,
    this.recordAccelerometer = true,
    this.gpsUpdateRateSeconds = 5,
  });
}
