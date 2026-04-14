import 'package:flutter/material.dart';

/// Represents a training zone for heart rate based training
class TrainingZone {
  final String name;
  final int minBpm;
  final int maxBpm;
  final Color color;
  final String description;

  TrainingZone({
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    required this.color,
    required this.description,
  });

  /// Get intensity percentage (0-100%)
  int get intensityPercentage {
    // Assuming max HR zones end at ~200 bpm for average adult
    // Calculate as percentage of 200 for consistency
    return ((minBpm + maxBpm) ~/ 2) ~/ 2;
  }

  /// Check if a BPM value falls within this zone
  bool contains(int bpm) => bpm >= minBpm && bpm <= maxBpm;

  @override
  String toString() => '$name ($minBpm-$maxBpm bpm)';
}

/// Standard training zones based on Karvonen formula or max HR percentage
class TrainingZones {
  static List<TrainingZone> getZonesForMaxHR(int maxHeartRate) {
    // Standard 5-zone model based on percentage of max HR
    final int z1Max = (maxHeartRate * 0.60).toInt();
    final int z2Min = (maxHeartRate * 0.60).toInt() + 1;
    final int z2Max = (maxHeartRate * 0.70).toInt();
    final int z3Min = (maxHeartRate * 0.70).toInt() + 1;
    final int z3Max = (maxHeartRate * 0.80).toInt();
    final int z4Min = (maxHeartRate * 0.80).toInt() + 1;
    final int z4Max = (maxHeartRate * 0.90).toInt();
    final int z5Min = (maxHeartRate * 0.90).toInt() + 1;
    final int z5Max = maxHeartRate;

    return [
      TrainingZone(
        name: 'Recovery',
        minBpm: 0,
        maxBpm: z1Max,
        color: const Color(0xFF4CAF50), // Green
        description: 'Easy recovery - builds aerobic base',
      ),
      TrainingZone(
        name: 'Aerobic',
        minBpm: z2Min,
        maxBpm: z2Max,
        color: const Color(0xFF2196F3), // Blue
        description: 'Sustainable pace - improves endurance',
      ),
      TrainingZone(
        name: 'Threshold',
        minBpm: z3Min,
        maxBpm: z3Max,
        color: const Color(0xFFFFC107), // Amber
        description: 'Hard effort - builds strength and FTP',
      ),
      TrainingZone(
        name: 'VO2 Max',
        minBpm: z4Min,
        maxBpm: z4Max,
        color: const Color(0xFFFF7043), // Deep Orange
        description: 'Very hard - improves max capacity',
      ),
      TrainingZone(
        name: 'Anaerobic',
        minBpm: z5Min,
        maxBpm: z5Max,
        color: const Color(0xFFF44336), // Red
        description: 'Max effort - sprint training',
      ),
    ];
  }

  /// Get zone for a specific BPM and max HR
  static TrainingZone? getZoneForBpm(int bpm, int maxHeartRate) {
    final zones = getZonesForMaxHR(maxHeartRate);
    try {
      return zones.firstWhere((zone) => zone.contains(bpm));
    } catch (e) {
      return null;
    }
  }

  /// Get zone name for a specific BPM
  static String getZoneNameForBpm(int bpm, int maxHeartRate) {
    final zone = getZoneForBpm(bpm, maxHeartRate);
    return zone?.name ?? 'Unknown';
  }

  /// Get zone color for a specific BPM
  static Color getZoneColorForBpm(int bpm, int maxHeartRate) {
    final zone = getZoneForBpm(bpm, maxHeartRate);
    return zone?.color ?? const Color(0xFFCCCCCC); // Gray default
  }

  /// Calculate the percentage of time in each zone
  /// [heartRateData] is a list of BPM values recorded during session
  static Map<String, double> calculateZoneDistribution(
    List<int> heartRateData,
    int maxHeartRate,
  ) {
    if (heartRateData.isEmpty) {
      return {};
    }

    final zones = getZonesForMaxHR(maxHeartRate);
    final distribution = <String, int>{};

    for (final zone in zones) {
      distribution[zone.name] = 0;
    }

    // Count occurrences in each zone
    for (final bpm in heartRateData) {
      final zone = getZoneForBpm(bpm, maxHeartRate);
      if (zone != null) {
        distribution[zone.name] = (distribution[zone.name] ?? 0) + 1;
      }
    }

    // Convert to percentages
    final result = <String, double>{};
    final total = heartRateData.length.toDouble();
    for (final entry in distribution.entries) {
      result[entry.key] = (entry.value / total) * 100;
    }

    return result;
  }
}
