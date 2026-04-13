part of 'heart_rate_bloc.dart';

abstract class HeartRateState extends Equatable {
  const HeartRateState();

  @override
  List<Object?> get props => [];
}

class HeartRateInitial extends HeartRateState {
  const HeartRateInitial();
}

class HeartRateMonitoring extends HeartRateState {
  final int bpm;
  final String zone; // 'recovery', 'aerobic', 'threshold', 'vo2max'
  final double avgBpm;
  final int minBpm;
  final int maxBpm;

  const HeartRateMonitoring({
    required this.bpm,
    required this.zone,
    required this.avgBpm,
    required this.minBpm,
    required this.maxBpm,
  });

  @override
  List<Object?> get props => [bpm, zone, avgBpm, minBpm, maxBpm];

  HeartRateMonitoring copyWith({
    int? bpm,
    String? zone,
    double? avgBpm,
    int? minBpm,
    int? maxBpm,
  }) {
    return HeartRateMonitoring(
      bpm: bpm ?? this.bpm,
      zone: zone ?? this.zone,
      avgBpm: avgBpm ?? this.avgBpm,
      minBpm: minBpm ?? this.minBpm,
      maxBpm: maxBpm ?? this.maxBpm,
    );
  }
}

class HeartRateError extends HeartRateState {
  final String message;

  const HeartRateError(this.message);

  @override
  List<Object?> get props => [message];
}
