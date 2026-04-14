import 'package:flutter/material.dart';

/// Represents detailed analytics for a training session
class SessionAnalytics {
  // Basic stats
  final double totalDistance;
  final Duration totalTime;
  final double averageSpeed;
  final double maxSpeed;
  final double averagePace;
  final double maxPace;

  // HR Stats (if available)
  final int? averageHeartRate;
  final int? maxHeartRate;
  final int? minHeartRate;
  final Map<String, double>? zoneDistribution; // Zone name -> percentage

  // Performance metrics
  final double efficiencyScore; // 0-100: how consistent the pace
  final List<MaxEffort>? maxEfforts;
  final double? variabilityIndex; // 0-100: variation in pace

  // Cadence stats (if available)
  final double? averageCadence;
  final double? maxCadence;
  final double? averageStrokeRate;
  final double? maxStrokeRate;

  // Altitude (if available)
  final int? elevationGain;
  final int? elevationLoss;
  final double? minAltitude;
  final double? maxAltitude;

  // Comparison with previous session
  final SessionComparison? comparisonWithPrevious;

  // Recommendations
  final List<String>? recommendations;

  SessionAnalytics({
    required this.totalDistance,
    required this.totalTime,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.averagePace,
    required this.maxPace,
    this.averageHeartRate,
    this.maxHeartRate,
    this.minHeartRate,
    this.zoneDistribution,
    required this.efficiencyScore,
    this.maxEfforts,
    this.variabilityIndex,
    this.averageCadence,
    this.maxCadence,
    this.averageStrokeRate,
    this.maxStrokeRate,
    this.elevationGain,
    this.elevationLoss,
    this.minAltitude,
    this.maxAltitude,
    this.comparisonWithPrevious,
    this.recommendations,
  });

  /// Get a rating badge based on efficiency score
  ({String label, Color color}) getEfficiencyBadge() {
    if (efficiencyScore >= 90) {
      return (label: 'Excellent', color: const Color(0xFF4CAF50));
    } else if (efficiencyScore >= 80) {
      return (label: 'Very Good', color: const Color(0xFF81C784));
    } else if (efficiencyScore >= 70) {
      return (label: 'Good', color: const Color(0xFFFFC107));
    } else if (efficiencyScore >= 60) {
      return (label: 'Fair', color: const Color(0xFFFF9800));
    } else {
      return (label: 'Needs Work', color: const Color(0xFFF44336));
    }
  }

  /// Get intensity level (0-100)
  int get intensityLevel {
    if (averageHeartRate == null) return 0;
    // Assuming maxHR ~200
    return ((averageHeartRate! / 200) * 100).toInt().clamp(0, 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDistance': totalDistance,
      'totalTimeSeconds': totalTime.inSeconds,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'averagePace': averagePace,
      'maxPace': maxPace,
      'averageHeartRate': averageHeartRate,
      'maxHeartRate': maxHeartRate,
      'minHeartRate': minHeartRate,
      'zoneDistribution': zoneDistribution,
      'efficiencyScore': efficiencyScore,
      'maxEfforts': maxEfforts?.map((e) => e.toJson()).toList(),
      'variabilityIndex': variabilityIndex,
      'averageCadence': averageCadence,
      'maxCadence': maxCadence,
      'averageStrokeRate': averageStrokeRate,
      'maxStrokeRate': maxStrokeRate,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'minAltitude': minAltitude,
      'maxAltitude': maxAltitude,
      'comparisonWithPrevious': comparisonWithPrevious?.toJson(),
      'recommendations': recommendations,
    };
  }
}

/// Represents a maximum effort detected during the session
class MaxEffort {
  final int number; // 1st, 2nd, 3rd max effort
  final Duration startTime;
  final Duration duration;
  final double distance;
  final double speed;
  final int? heartRate;

  MaxEffort({
    required this.number,
    required this.startTime,
    required this.duration,
    required this.distance,
    required this.speed,
    this.heartRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'startTimeSeconds': startTime.inSeconds,
      'durationSeconds': duration.inSeconds,
      'distance': distance,
      'speed': speed,
      'heartRate': heartRate,
    };
  }
}

/// Represents comparison between current and previous session
class SessionComparison {
  final double distanceDifference; // positive = better
  final double speedDifference; // positive = better
  final double efficiencyDifference; // positive = better
  final int? heartRateDifference; // positive = worse (more effort)
  final String trend; // 'improving', 'declining', 'stable'

  SessionComparison({
    required this.distanceDifference,
    required this.speedDifference,
    required this.efficiencyDifference,
    this.heartRateDifference,
    required this.trend,
  });

  String get trendEmoji {
    if (trend == 'improving') return '📈';
    if (trend == 'declining') return '📉';
    return '➡️';
  }

  String getTrendDescription() {
    if (trend == 'improving') {
      return 'Great progress! You\'re getting faster and more efficient.';
    } else if (trend == 'declining') {
      return 'Take it easier next time. Rest and recovery are important.';
    } else {
      return 'Consistent performance. Keep up the good work!';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'distanceDifference': distanceDifference,
      'speedDifference': speedDifference,
      'efficiencyDifference': efficiencyDifference,
      'heartRateDifference': heartRateDifference,
      'trend': trend,
    };
  }
}
