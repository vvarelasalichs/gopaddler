import 'package:flutter_test/flutter_test.dart';
import 'package:gopaddler_flutter/data/models/session.dart';

void main() {
  group('Session Model Tests', () {
    group('Session creation', () {
      test('creates session with valid data', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final session = Session(
          id: 'test-session',
          startTime: now,
          endTime: now.add(const Duration(minutes: 30)),
          sportType: 'kayaking',
          gpsPoints: [],
          measurements: [],
          splits: [],
          settings: const SessionSettings(),
          isSynced: false,
        );

        // Assert
        expect(session.id, 'test-session');
        expect(session.sportType, 'kayaking');
        expect(session.totalDistance, 0); // No GPS points yet
        expect(session.isSynced, false);
      });
    });

    group('Split model', () {
      test('creates split with valid data', () {
        // Arrange & Act
        final split = Split(
          number: 1,
          name: 'Warm-up',
          duration: const Duration(minutes: 10),
          distance: 1500,
          averageSpeed: 5.0,
          maxSpeed: 5.5,
          averagePace: 2.0,
          averageHeartRate: 130,
          maxHeartRate: 145,
          averageCadence: 60,
          averageStrokeRate: 50,
        );

        // Assert
        expect(split.number, 1);
        expect(split.name, 'Warm-up');
        expect(split.distance, 1500);
        expect(split.averageHeartRate, 130);
      });

      test('calculates intensity level correctly', () {
        // Arrange
        final split = Split(
          number: 1,
          duration: const Duration(minutes: 10),
          distance: 1500,
          averageSpeed: 5.0,
          averagePace: 2.0,
          averageHeartRate: 160,
          maxHeartRate: 170,
        );

        // Act
        final intensity = split.getIntensityLevel(6.0);

        // Assert
        expect(intensity, isNotNull);
      });

      test('compares speed with average', () {
        // Arrange
        final split = Split(
          number: 1,
          duration: const Duration(minutes: 10),
          distance: 1500,
          averageSpeed: 6.0,
          maxSpeed: 6.5,
          averagePace: 2.0,
        );

        // Act - 6.0 > 5.0 * 1.1 (5.5) = true
        final faster = split.isFasterThanAverage(5.0);

        // Assert
        expect(faster, true);
      });
    });

    group('GpsPoint model', () {
      test('creates GPS point with valid coordinates', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final point = GpsPoint(
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 10.0,
          speed: 5.0,
          heading: 45.0,
          accuracy: 5.0,
          timestamp: now,
        );

        // Assert
        expect(point.latitude, 40.7128);
        expect(point.longitude, -74.0060);
        expect(point.altitude, 10.0);
      });
    });

    group('Measurement model', () {
      test('creates measurement with heartRate type', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final measurement = Measurement(
          type: 'heartRate',
          value: 150.0,
          unit: 'bpm',
          timestamp: now,
        );

        // Assert
        expect(measurement.type, 'heartRate');
        expect(measurement.value, 150.0);
        expect(measurement.unit, 'bpm');
      });

      test('creates measurement with cadence type', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final measurement = Measurement(
          type: 'cadence',
          value: 70.0,
          unit: 'rpm',
          timestamp: now,
        );

        // Assert
        expect(measurement.type, 'cadence');
        expect(measurement.value, 70.0);
      });

      test('serializes to JSON correctly', () {
        // Arrange
        final now = DateTime.now();
        final measurement = Measurement(
          type: 'heartRate',
          value: 150.0,
          unit: 'bpm',
          timestamp: now,
        );

        // Act
        final json = measurement.toJson();

        // Assert
        expect(json['type'], 'heartRate');
        expect(json['value'], 150.0);
        expect(json['unit'], 'bpm');
      });
    });

    group('Session serialization', () {
      test('converts session to JSON and back', () {
        // Arrange
        final now = DateTime.now();
        final originalSession = Session(
          id: 'test-session',
          startTime: now,
          endTime: now.add(const Duration(minutes: 30)),
          sportType: 'kayaking',
          gpsPoints: [],
          measurements: [],
          splits: [],
          settings: const SessionSettings(),
          isSynced: false,
        );

        // Act
        final json = originalSession.toJson();
        final restoredSession = Session.fromJson(json);

        // Assert
        expect(restoredSession.id, originalSession.id);
        expect(restoredSession.sportType, originalSession.sportType);
        expect(restoredSession.totalDistance, originalSession.totalDistance);
      });
    });
  });
}
