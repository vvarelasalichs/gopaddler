part of 'session_bloc.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionInProgress extends SessionState {
  final Session session;
  final bool isPaused;
  final Duration elapsed;

  const SessionInProgress({
    required this.session,
    this.isPaused = false,
    this.elapsed = Duration.zero,
  });

  @override
  List<Object?> get props => [session, isPaused, elapsed];
}

class SessionPaused extends SessionState {
  final Session session;
  final Duration elapsed;

  const SessionPaused({
    required this.session,
    this.elapsed = Duration.zero,
  });

  @override
  List<Object?> get props => [session, elapsed];
}

class SessionCompleted extends SessionState {
  final Session session;
  final Duration totalDuration;
  final double totalDistance;
  final double averageSpeed;

  const SessionCompleted({
    required this.session,
    required this.totalDuration,
    required this.totalDistance,
    required this.averageSpeed,
  });

  @override
  List<Object?> get props =>
      [session, totalDuration, totalDistance, averageSpeed];
}

class SessionLoaded extends SessionState {
  final Session session;

  const SessionLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionSynced extends SessionState {
  final Session session;

  const SessionSynced(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
