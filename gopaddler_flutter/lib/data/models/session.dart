import 'dart:math';

// Main Session Model
class Session {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final String sportType; // 'canoeing', 'cycling'
  final String? boatType;
  final List<GpsPoint> gpsPoints;
  final List<Measurement> measurements;
  final List<Split> splits;
  final List<HeartRateZone> zones;
  final SessionSettings settings;
  bool isSynced;
  final String? notes;

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
    this.notes,
  });

  // Getters para cálculos
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get totalDistance {
    if (gpsPoints.isEmpty) return 0.0;
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
    if (gpsPoints.isEmpty) return 0.0;
    return gpsPoints.fold(
        0.0, (prev, point) => point.speed > prev ? point.speed : prev);
  }

  double getEfficiencyScore() {
    if (gpsPoints.length < 2) return 0.0;
    
    // Calcular velocidades
    final speeds = <double>[];
    for (int i = 0; i < gpsPoints.length - 1; i++) {
      speeds.add(gpsPoints[i].speed);
    }
    speeds.add(gpsPoints.last.speed);
    
    if (speeds.isEmpty) return 0.0;
    
    // Calcular media
    final mean = speeds.reduce((a, b) => a + b) / speeds.length;
    
    // Calcular desviación estándar
    final variance =
        speeds.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) /
            speeds.length;
    final stdDev = sqrt(variance);
    
    // Convertir a eficiencia (menos variación = más eficiencia)
    // Si no hay variación (todos a veloc media), eficiencia = 100
    // Si hay mucha variación, eficiencia baja
    final coefficientOfVariation = mean > 0 ? stdDev / mean : 0.0;
    
    // Normalizar entre 0-100
    return (100 * (1 - ((coefficientOfVariation / 3).clamp(0.0, 1.0))))
        .clamp(0.0, 100.0);
  }

  // Serialización para base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'sportType': sportType,
      'boatType': boatType,
      'totalDistance': totalDistance,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'isSynced': isSynced ? 1 : 0,
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // JSON para API
  Map<String, dynamic> toJson() {
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
      'notes': notes,
      'gpsPoints': gpsPoints.map((p) => p.toJson()).toList(),
      'measurements': measurements.map((m) => m.toJson()).toList(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'zones': zones.map((z) => z.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      startTime:
          DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      sportType: map['sportType'] ?? 'canoeing',
      boatType: map['boatType'],
      notes: map['notes'],
      settings: SessionSettings.fromMap(map['settings'] ?? {}),
      isSynced: (map['isSynced'] ?? 0) == 1,
    );
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      sportType: json['sportType'] ?? 'canoeing',
      boatType: json['boatType'],
      notes: json['notes'],
      gpsPoints: (json['gpsPoints'] as List? ?? [])
          .map((p) => GpsPoint.fromJson(p))
          .toList(),
      measurements: (json['measurements'] as List? ?? [])
          .map((m) => Measurement.fromJson(m))
          .toList(),
      splits: (json['splits'] as List? ?? [])
          .map((s) => Split.fromJson(s))
          .toList(),
      zones: (json['zones'] as List? ?? [])
          .map((z) => HeartRateZone.fromJson(z))
          .toList(),
      settings: SessionSettings.fromJson(json['settings'] ?? {}),
    );
  }
}

// GPS Point Model
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

  /// Calcula distancia a otro punto usando fórmula Haversine
  double distanceTo(GpsPoint other) {
    const earthRadius = 6371000; // metros
    final dLat = _toRad(other.latitude - latitude);
    final dLon = _toRad(other.longitude - longitude);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRad(latitude)) *
            cos(_toRad(other.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory GpsPoint.fromMap(Map<String, dynamic> map) {
    return GpsPoint(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      altitude: map['altitude'] ?? 0.0,
      accuracy: map['accuracy'] ?? 0.0,
      speed: map['speed'] ?? 0.0,
      heading: map['heading'] ?? 0.0,
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory GpsPoint.fromJson(Map<String, dynamic> json) {
    return GpsPoint.fromMap(json);
  }
}

// Measurement Model
class Measurement {
  final String type; // speed, pace, distance, cadence, strokeRate, heartRate
  final double value;
  final String unit; // m/s, min/km, m, rpm, strokes/min, bpm
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

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      type: map['type'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement.fromMap(json);
  }
}

// Split Model para intervalos
class Split {
  final int number;
  final String? name; // e.g., "Warm-up", "Main set", "Cool-down"
  final Duration duration;
  final double distance;
  final double averageSpeed;
  final double maxSpeed;
  final double averagePace;
  final int? averageHeartRate;
  final int? maxHeartRate;
  final int? averageCadence;
  final int? averageStrokeRate;
  final bool isMaxEffort; // Indicates if this was a high-intensity split

  Split({
    required this.number,
    this.name,
    required this.duration,
    required this.distance,
    required this.averageSpeed,
    this.maxSpeed = 0.0,
    required this.averagePace,
    this.averageHeartRate,
    this.maxHeartRate,
    this.averageCadence,
    this.averageStrokeRate,
    this.isMaxEffort = false,
  });

  /// Calculate intensity level (0-100) based on speed
  int getIntensityLevel(double maxSessionSpeed) {
    if (maxSessionSpeed == 0) return 0;
    return ((averageSpeed / maxSessionSpeed) * 100).toInt().clamp(0, 100);
  }

  /// Check if this split was faster than average
  bool isFasterThanAverage(double sessionAverageSpeed) {
    return averageSpeed > sessionAverageSpeed * 1.1; // 10% faster
  }

  /// Format split time for display (e.g., "5:30")
  String formatTime() {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'durationSeconds': duration.inSeconds,
      'distance': distance,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'averagePace': averagePace,
      'averageHeartRate': averageHeartRate,
      'maxHeartRate': maxHeartRate,
      'averageCadence': averageCadence,
      'averageStrokeRate': averageStrokeRate,
      'isMaxEffort': isMaxEffort ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'duration': duration.inSeconds,
      'distance': distance,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'averagePace': averagePace,
      'averageHeartRate': averageHeartRate,
      'maxHeartRate': maxHeartRate,
      'averageCadence': averageCadence,
      'averageStrokeRate': averageStrokeRate,
      'isMaxEffort': isMaxEffort,
    };
  }

  factory Split.fromMap(Map<String, dynamic> map) {
    return Split(
      number: map['number'] ?? 0,
      name: map['name'],
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      distance: (map['distance'] ?? 0.0).toDouble(),
      averageSpeed: (map['averageSpeed'] ?? 0.0).toDouble(),
      maxSpeed: (map['maxSpeed'] ?? 0.0).toDouble(),
      averagePace: (map['averagePace'] ?? 0.0).toDouble(),
      averageHeartRate: map['averageHeartRate'],
      maxHeartRate: map['maxHeartRate'],
      averageCadence: map['averageCadence'],
      averageStrokeRate: map['averageStrokeRate'],
      isMaxEffort: (map['isMaxEffort'] ?? 0) == 1,
    );
  }

  factory Split.fromJson(Map<String, dynamic> json) {
    return Split.fromMap(json);
  }
}

// Heart Rate Zone para análisis
class HeartRateZone {
  final int zone; // 1-5
  final int minBpm;
  final int maxBpm;
  final Duration timeInZone;
  final double percentage;

  HeartRateZone({
    required this.zone,
    required this.minBpm,
    required this.maxBpm,
    required this.timeInZone,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'zone': zone,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'timeInZoneSeconds': timeInZone.inSeconds,
      'percentage': percentage,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'timeInZone': timeInZone.inSeconds,
      'percentage': percentage,
    };
  }

  factory HeartRateZone.fromMap(Map<String, dynamic> map) {
    return HeartRateZone(
      zone: map['zone'] ?? 0,
      minBpm: map['minBpm'] ?? 0,
      maxBpm: map['maxBpm'] ?? 0,
      timeInZone: Duration(seconds: map['timeInZoneSeconds'] ?? 0),
      percentage: (map['percentage'] ?? 0.0).toDouble(),
    );
  }

  factory HeartRateZone.fromJson(Map<String, dynamic> json) {
    return HeartRateZone.fromMap(json);
  }
}

// Session Settings
class SessionSettings {
  final bool recordGps;
  final bool recordHeartRate;
  final bool recordCadence;
  final bool recordPace;
  final int gpsIntervalSeconds;
  final String? notes;
  final Map<String, dynamic> metadata; // Para datos adicionales

  const SessionSettings({
    this.recordGps = true,
    this.recordHeartRate = true,
    this.recordCadence = true,
    this.recordPace = true,
    this.gpsIntervalSeconds = 5,
    this.notes,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'recordGps': recordGps ? 1 : 0,
      'recordHeartRate': recordHeartRate ? 1 : 0,
      'recordCadence': recordCadence ? 1 : 0,
      'recordPace': recordPace ? 1 : 0,
      'gpsIntervalSeconds': gpsIntervalSeconds,
      'notes': notes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'recordGps': recordGps,
      'recordHeartRate': recordHeartRate,
      'recordCadence': recordCadence,
      'recordPace': recordPace,
      'gpsIntervalSeconds': gpsIntervalSeconds,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory SessionSettings.fromMap(Map<String, dynamic> map) {
    return SessionSettings(
      recordGps: (map['recordGps'] ?? 1) == 1,
      recordHeartRate: (map['recordHeartRate'] ?? 1) == 1,
      recordCadence: (map['recordCadence'] ?? 1) == 1,
      recordPace: (map['recordPace'] ?? 1) == 1,
      gpsIntervalSeconds: map['gpsIntervalSeconds'] ?? 5,
      notes: map['notes'],
    );
  }

  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      recordGps: json['recordGps'] ?? true,
      recordHeartRate: json['recordHeartRate'] ?? true,
      recordCadence: json['recordCadence'] ?? true,
      recordPace: json['recordPace'] ?? true,
      gpsIntervalSeconds: json['gpsIntervalSeconds'] ?? 5,
      notes: json['notes'],
      metadata: json['metadata'] ?? {},
    );
  }
}
