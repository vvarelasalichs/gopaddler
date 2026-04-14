import 'dart:math';
import '../../data/models/session.dart';
import '../models/training_zones.dart';
import '../models/session_analytics.dart';
import '../../utils/app_logger.dart';

/// Service for advanced analytics and performance analysis
class AnalyticsService {
  /// Calculate comprehensive analytics for a session
  SessionAnalytics analyzeSession(
    Session session,
    Session? previousSession,
    int maxHeartRate,
  ) {
    try {
      // Basic stats
      final totalDistance = session.totalDistance / 1000; // Convert to km
      final totalTime = session.duration;
      final averageSpeed = session.averageSpeed;
      final maxSpeed = session.maxSpeed;
      final averagePace = totalDistance > 0 ? (totalTime.inMinutes / totalDistance) : 0;
      final maxPace = maxSpeed > 0 ? 60 / maxSpeed : 0;

      // HR stats
      final List<int> heartRates = _extractHeartRates(session);
      final averageHeartRate = heartRates.isNotEmpty
          ? (heartRates.reduce((a, b) => a + b) / heartRates.length).toInt()
          : null;
      final maxHeartRateValue = heartRates.isNotEmpty ? heartRates.reduce((a, b) => a > b ? a : b) : null;
      final minHeartRateValue = heartRates.isNotEmpty ? heartRates.reduce((a, b) => a < b ? a : b) : null;

      // Zone distribution
      final Map<String, double>? zoneDistribution = heartRates.isNotEmpty
          ? TrainingZones.calculateZoneDistribution(heartRates, maxHeartRate)
          : null;

      // Performance metrics
      final efficiencyScore = session.getEfficiencyScore();
      final variabilityIndex = _calculateVariabilityIndex(session);
      final maxEfforts = _detectMaxEfforts(session, 3);

      // Cadence stats
      final List<int> cadenceData = _extractCadenceData(session);
      final averageCadence = cadenceData.isNotEmpty
          ? (cadenceData.reduce((a, b) => a + b) / cadenceData.length).toDouble()
          : null;
      final maxCadence = cadenceData.isNotEmpty
          ? cadenceData.reduce((a, b) => a > b ? a : b).toDouble()
          : null;

      // Stroke rate stats
      final List<int> strokeRates = _extractStrokeRates(session);
      final averageStrokeRate = strokeRates.isNotEmpty
          ? (strokeRates.reduce((a, b) => a + b) / strokeRates.length).toDouble()
          : null;
      final maxStrokeRate = strokeRates.isNotEmpty
          ? strokeRates.reduce((a, b) => a > b ? a : b).toDouble()
          : null;

      // Elevation stats (if GPS has altitude)
      final elevationStats = _calculateElevationStats(session);

      // Comparison with previous session
      SessionComparison? comparison;
      if (previousSession != null) {
        comparison = _compareWithPreviousSession(session, previousSession);
      }

      // Generate recommendations
      final recommendations = _generateRecommendations(
        efficiencyScore,
        averageHeartRate,
        maxHeartRate,
        comparison,
        variabilityIndex,
      );

      AppLogger.info('Session analyzed: efficiency=$efficiencyScore, avgSpeed=$averageSpeed');

      return SessionAnalytics(
        totalDistance: totalDistance,
        totalTime: totalTime,
        averageSpeed: averageSpeed,
        maxSpeed: maxSpeed,
        averagePace: averagePace,
        maxPace: maxPace,
        averageHeartRate: averageHeartRate,
        maxHeartRate: maxHeartRateValue,
        minHeartRate: minHeartRateValue,
        zoneDistribution: zoneDistribution,
        efficiencyScore: efficiencyScore,
        maxEfforts: maxEfforts,
        variabilityIndex: variabilityIndex,
        averageCadence: averageCadence,
        maxCadence: maxCadence,
        averageStrokeRate: averageStrokeRate,
        maxStrokeRate: maxStrokeRate,
        elevationGain: elevationStats['gain'],
        elevationLoss: elevationStats['loss'],
        minAltitude: elevationStats['min'],
        maxAltitude: elevationStats['max'],
        comparisonWithPrevious: comparison,
        recommendations: recommendations,
      );
    } catch (e) {
      AppLogger.error('Error analyzing session: $e');
      rethrow;
    }
  }

  /// Extract heart rate data from measurements
  List<int> _extractHeartRates(Session session) {
    final rates = <int>[];
    for (final measurement in session.measurements) {
      if (measurement.heartRate != null) {
        rates.add(measurement.heartRate!);
      }
    }
    return rates;
  }

  /// Extract cadence data
  List<int> _extractCadenceData(Session session) {
    final cadences = <int>[];
    for (final measurement in session.measurements) {
      if (measurement.cadence != null) {
        cadences.add(measurement.cadence!);
      }
    }
    return cadences;
  }

  /// Extract stroke rates
  List<int> _extractStrokeRates(Session session) {
    final rates = <int>[];
    for (final measurement in session.measurements) {
      if (measurement.strokeRate != null) {
        rates.add(measurement.strokeRate!);
      }
    }
    return rates;
  }

  /// Calculate variability index (0-100: lower = more consistent)
  double _calculateVariabilityIndex(Session session) {
    if (session.gpsPoints.length < 2) return 0.0;

    final speeds = session.gpsPoints.map((p) => p.speed).toList();
    if (speeds.isEmpty) return 0.0;

    final mean = speeds.reduce((a, b) => a + b) / speeds.length;
    if (mean == 0) return 0.0;

    final variance = speeds.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) / speeds.length;
    final stdDev = sqrt(variance);
    final coefficientOfVariation = stdDev / mean;

    // Convert to 0-100 scale (lower CV = higher consistency)
    return (100 * (1 - ((coefficientOfVariation / 3).clamp(0.0, 1.0)))).clamp(0.0, 100.0);
  }

  /// Detect maximum efforts in the session
  List<MaxEffort> _detectMaxEfforts(Session session, int count) {
    if (session.splits.isEmpty) return [];

    // Sort splits by speed (descending)
    final sortedSplits = List<Split>.from(session.splits);
    sortedSplits.sort((a, b) => b.averageSpeed.compareTo(a.averageSpeed));

    final maxEfforts = <MaxEffort>[];
    for (int i = 0; i < min(count, sortedSplits.length); i++) {
      final split = sortedSplits[i];
      // Calculate start time (approximate based on split number)
      final startTime = Duration(
        seconds: split.number * (session.duration.inSeconds ~/ (session.splits.length + 1)),
      );

      maxEfforts.add(
        MaxEffort(
          number: i + 1,
          startTime: startTime,
          duration: split.duration,
          distance: split.distance,
          speed: split.averageSpeed,
          heartRate: split.averageHeartRate,
        ),
      );
    }

    return maxEfforts;
  }

  /// Calculate elevation statistics from GPS points
  Map<String, int?> _calculateElevationStats(Session session) {
    if (session.gpsPoints.isEmpty) {
      return {'gain': null, 'loss': null, 'min': null, 'max': null};
    }

    final altitudes = session.gpsPoints
        .where((p) => p.altitude != null)
        .map((p) => p.altitude!)
        .toList();

    if (altitudes.isEmpty) {
      return {'gain': null, 'loss': null, 'min': null, 'max': null};
    }

    int elevationGain = 0;
    int elevationLoss = 0;

    for (int i = 1; i < altitudes.length; i++) {
      final diff = altitudes[i] - altitudes[i - 1];
      if (diff > 0) {
        elevationGain += diff;
      } else {
        elevationLoss += diff.abs();
      }
    }

    final minAlt = altitudes.reduce((a, b) => a < b ? a : b);
    final maxAlt = altitudes.reduce((a, b) => a > b ? a : b);

    return {
      'gain': elevationGain,
      'loss': elevationLoss,
      'min': minAlt,
      'max': maxAlt,
    };
  }

  /// Compare current session with previous
  SessionComparison _compareWithPreviousSession(
    Session current,
    Session previous,
  ) {
    final currentDist = current.totalDistance / 1000;
    final prevDist = previous.totalDistance / 1000;
    final distDiff = currentDist - prevDist;

    final speedDiff = current.averageSpeed - previous.averageSpeed;
    final effDiff = current.getEfficiencyScore() - previous.getEfficiencyScore();

    final currHR = _extractHeartRates(current);
    final prevHR = _extractHeartRates(previous);
    int? hrDiff;
    if (currHR.isNotEmpty && prevHR.isNotEmpty) {
      final currAvg = (currHR.reduce((a, b) => a + b) / currHR.length).toInt();
      final prevAvg = (prevHR.reduce((a, b) => a + b) / prevHR.length).toInt();
      hrDiff = currAvg - prevAvg;
    }

    // Determine trend
    late String trend;
    if (speedDiff > 0.5 && effDiff > 2) {
      trend = 'improving';
    } else if (speedDiff < -0.5 || effDiff < -5) {
      trend = 'declining';
    } else {
      trend = 'stable';
    }

    return SessionComparison(
      distanceDifference: distDiff,
      speedDifference: speedDiff,
      efficiencyDifference: effDiff,
      heartRateDifference: hrDiff,
      trend: trend,
    );
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(
    double efficiencyScore,
    int? averageHeartRate,
    int maxHeartRate,
    SessionComparison? comparison,
    double? variabilityIndex,
  ) {
    final recommendations = <String>[];

    // Efficiency recommendations
    if (efficiencyScore < 60) {
      recommendations.add('Try to maintain a more consistent pace');
    } else if (efficiencyScore > 85) {
      recommendations.add('Excellent pace consistency! Keep it up!');
    }

    // HR zone recommendations
    if (averageHeartRate != null) {
      final intensityPercent = (averageHeartRate / maxHeartRate) * 100;
      if (intensityPercent < 50) {
        recommendations.add('Consider increasing intensity for aerobic training');
      } else if (intensityPercent > 85) {
        recommendations.add('Good high-intensity work. Remember to include recovery sessions');
      }
    }

    // Variability recommendations
    if (variabilityIndex != null && variabilityIndex < 50) {
      recommendations.add('Work on pace variability - try different strategies');
    }

    // Comparison recommendations
    if (comparison != null) {
      if (comparison.trend == 'improving') {
        recommendations.add('Great improvement! You\'re on the right track');
      } else if (comparison.trend == 'declining') {
        recommendations.add('Take some rest days and focus on recovery');
      }
      if (comparison.heartRateDifference != null && comparison.heartRateDifference! > 5) {
        recommendations.add('Heart rate is higher than last session - ensure adequate recovery');
      }
    }

    return recommendations.isNotEmpty ? recommendations : ['Session completed successfully!'];
  }
}
