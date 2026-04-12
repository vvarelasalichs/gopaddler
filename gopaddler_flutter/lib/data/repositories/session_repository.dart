import '../models/session.dart';
import '../services/database_service.dart';
import '../../utils/app_logger.dart';

abstract class SessionRepository {
  Future<void> saveSession(Session session);
  Future<Session?> getSessionById(String id);
  Future<List<Session>> getAllSessions();
  Future<void> updateSession(Session session);
  Future<void> deleteSession(String id);
  Future<int> getSessionCount();
  Future<void> clearAllData();
}

class SessionRepositoryImpl implements SessionRepository {
  final DatabaseService _database;

  SessionRepositoryImpl(this._database);

  @override
  Future<void> saveSession(Session session) async {
    try {
      await _database.insertSession(session);

      // Guardar puntos GPS
      for (final point in session.gpsPoints) {
        await _database.insertGpsPoint(session.id, point);
      }

      // Guardar mediciones
      for (final measurement in session.measurements) {
        await _database.insertMeasurement(session.id, measurement);
      }

      AppLogger.debug(
        'Session saved with ${session.gpsPoints.length} GPS points and ${session.measurements.length} measurements',
        tag: 'SessionRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Error saving session',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<Session?> getSessionById(String id) async {
    try {
      final session = await _database.getSession(id);
      if (session == null) return null;

      // Cargar puntos GPS
      final gpsPoints = await _database.getGpsPoints(id);

      // Cargar mediciones
      final measurements = await _database.getMeasurements(id);

      // Crear nueva sesión con datos completos
      return Session(
        id: session.id,
        startTime: session.startTime,
        endTime: session.endTime,
        sportType: session.sportType,
        boatType: session.boatType,
        gpsPoints: gpsPoints,
        measurements: measurements,
        settings: session.settings,
        isSynced: session.isSynced,
      );
    } catch (e) {
      AppLogger.error(
        'Error getting session by ID',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<Session>> getAllSessions() async {
    try {
      final sessions = await _database.getAllSessions();

      // Cargar datos relacionados para cada sesión
      final fullSessions = <Session>[];
      for (final session in sessions) {
        final gpsPoints = await _database.getGpsPoints(session.id);
        final measurements = await _database.getMeasurements(session.id);

        fullSessions.add(
          Session(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            sportType: session.sportType,
            boatType: session.boatType,
            gpsPoints: gpsPoints,
            measurements: measurements,
            settings: session.settings,
            isSynced: session.isSynced,
          ),
        );
      }

      return fullSessions;
    } catch (e) {
      AppLogger.error(
        'Error getting all sessions',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateSession(Session session) async {
    try {
      await _database.updateSession(session);
      AppLogger.debug('Session updated: ${session.id}',
          tag: 'SessionRepository');
    } catch (e) {
      AppLogger.error(
        'Error updating session',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await _database.deleteSession(id);
      AppLogger.debug('Session deleted: $id', tag: 'SessionRepository');
    } catch (e) {
      AppLogger.error(
        'Error deleting session',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<int> getSessionCount() async {
    try {
      return await _database.getSessionCount();
    } catch (e) {
      AppLogger.error(
        'Error getting session count',
        tag: 'SessionRepository',
        exception: e,
      );
      return 0;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _database.clearAllData();
      AppLogger.warning('All data cleared from repository',
          tag: 'SessionRepository');
    } catch (e) {
      AppLogger.error(
        'Error clearing all data',
        tag: 'SessionRepository',
        exception: e,
      );
      rethrow;
    }
  }
}
