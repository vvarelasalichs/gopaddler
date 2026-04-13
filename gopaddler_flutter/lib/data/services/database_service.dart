import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session.dart';
import '../models/sync_queue.dart';
import '../../utils/app_logger.dart';

class DatabaseService {
  static const String _dbName = 'gopaddler.db';
  static const int _dbVersion = 1;

  // Tabla sessions
  static const String tableSession = 'sessions';
  static const String colSessionId = 'id';
  static const String colStartTime = 'startTime';
  static const String colEndTime = 'endTime';
  static const String colSportType = 'sportType';
  static const String colBoatType = 'boatType';
  static const String colTotalDistance = 'totalDistance';
  static const String colAverageSpeed = 'averageSpeed';
  static const String colMaxSpeed = 'maxSpeed';
  static const String colIsSynced = 'isSynced';
  static const String colCreatedAt = 'createdAt';

  // Tabla gps_points
  static const String tableGpsPoint = 'gps_points';
  static const String colGpsPointId = 'id';
  static const String colSessionId2 = 'sessionId';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colAltitude = 'altitude';
  static const String colAccuracy = 'accuracy';
  static const String colSpeed = 'speed';
  static const String colHeading = 'heading';
  static const String colTimestamp = 'timestamp';

  // Tabla measurements
  static const String tableMeasurement = 'measurements';
  static const String colMeasurementId = 'id';
  static const String colSessionId3 = 'sessionId';
  static const String colType = 'type';
  static const String colValue = 'value';
  static const String colUnit = 'unit';
  static const String colTimestamp2 = 'timestamp';

  // Tabla sync_queue
  static const String tableSyncQueue = 'sync_queue';
  static const String colSyncQueueId = 'id';
  static const String colSyncSessionId = 'sessionId';
  static const String colSyncTimestamp = 'timestamp';
  static const String colSyncStatus = 'status';
  static const String colSyncRetryCount = 'retryCount';
  static const String colSyncLastError = 'lastError';
  static const String colSyncLastAttempt = 'lastSyncAttempt';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    AppLogger.info('Initializing database...', tag: 'DatabaseService');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables...', tag: 'DatabaseService');

    // Crear tabla de sesiones
    await db.execute('''
      CREATE TABLE $tableSession (
        $colSessionId TEXT PRIMARY KEY,
        $colStartTime TEXT NOT NULL,
        $colEndTime TEXT,
        $colSportType TEXT NOT NULL,
        $colBoatType TEXT,
        $colTotalDistance REAL,
        $colAverageSpeed REAL,
        $colMaxSpeed REAL,
        $colIsSynced INTEGER DEFAULT 0,
        $colCreatedAt TEXT NOT NULL
      )
    ''');

    // Crear tabla de puntos GPS
    await db.execute('''
      CREATE TABLE $tableGpsPoint (
        $colGpsPointId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSessionId2 TEXT NOT NULL,
        $colLatitude REAL NOT NULL,
        $colLongitude REAL NOT NULL,
        $colAltitude REAL,
        $colAccuracy REAL,
        $colSpeed REAL,
        $colHeading REAL,
        $colTimestamp TEXT NOT NULL,
        FOREIGN KEY ($colSessionId2) REFERENCES $tableSession($colSessionId) ON DELETE CASCADE
      )
    ''');

    // Crear tabla de mediciones
    await db.execute('''
      CREATE TABLE $tableMeasurement (
        $colMeasurementId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSessionId3 TEXT NOT NULL,
        $colType TEXT NOT NULL,
        $colValue REAL NOT NULL,
        $colUnit TEXT NOT NULL,
        $colTimestamp2 TEXT NOT NULL,
        FOREIGN KEY ($colSessionId3) REFERENCES $tableSession($colSessionId) ON DELETE CASCADE
      )
    ''');

    // Crear índices para mejorar rendimiento
    await db.execute(
        'CREATE INDEX idx_sessionId ON $tableGpsPoint($colSessionId2)');
    await db.execute(
        'CREATE INDEX idx_sessionId2 ON $tableMeasurement($colSessionId3)');
    await db
        .execute('CREATE INDEX idx_startTime ON $tableSession($colStartTime)');

    // Crear tabla de sync_queue
    await db.execute('''
      CREATE TABLE $tableSyncQueue (
        $colSyncQueueId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSyncSessionId TEXT NOT NULL UNIQUE,
        $colSyncTimestamp INTEGER NOT NULL,
        $colSyncStatus TEXT NOT NULL,
        $colSyncRetryCount INTEGER DEFAULT 0,
        $colSyncLastError TEXT,
        $colSyncLastAttempt INTEGER,
        FOREIGN KEY ($colSyncSessionId) REFERENCES $tableSession($colSessionId) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_syncStatus ON $tableSyncQueue($colSyncStatus)');
    await db.execute(
        'CREATE INDEX idx_syncSessionId ON $tableSyncQueue($colSyncSessionId)');

    AppLogger.info('Database tables created successfully',
        tag: 'DatabaseService');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info(
      'Upgrading database from v$oldVersion to v$newVersion',
      tag: 'DatabaseService',
    );
    // TODO: Implementar migrations cuando haya cambios en schema
  }

  // CRUD Operations para Sessions

  Future<void> insertSession(Session session) async {
    try {
      final db = await database;
      await db.insert(
        tableSession,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.debug('Session inserted: ${session.id}',
          tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error inserting session',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<Session?> getSession(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableSession,
        where: '$colSessionId = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return Session.fromMap(maps.first);
    } catch (e) {
      AppLogger.error(
        'Error getting session',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<List<Session>> getAllSessions() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableSession,
        orderBy: '$colStartTime DESC',
      );

      return maps.map((map) => Session.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error(
        'Error getting all sessions',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<void> updateSession(Session session) async {
    try {
      final db = await database;
      await db.update(
        tableSession,
        session.toMap(),
        where: '$colSessionId = ?',
        whereArgs: [session.id],
      );
      AppLogger.debug('Session updated: ${session.id}', tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error updating session',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final db = await database;
      await db.delete(
        tableSession,
        where: '$colSessionId = ?',
        whereArgs: [id],
      );
      AppLogger.debug('Session deleted: $id', tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error deleting session',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  // CRUD Operations para GPS Points

  Future<void> insertGpsPoint(String sessionId, GpsPoint point) async {
    try {
      final db = await database;
      final map = point.toMap();
      map['sessionId'] = sessionId;
      await db.insert(tableGpsPoint, map);
    } catch (e) {
      AppLogger.error(
        'Error inserting GPS point',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<List<GpsPoint>> getGpsPoints(String sessionId) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableGpsPoint,
        where: '$colSessionId2 = ?',
        whereArgs: [sessionId],
        orderBy: '$colTimestamp ASC',
      );

      return maps.map((map) => GpsPoint.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error(
        'Error getting GPS points',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  // CRUD Operations para Measurements

  Future<void> insertMeasurement(
      String sessionId, Measurement measurement) async {
    try {
      final db = await database;
      final map = measurement.toMap();
      map['sessionId'] = sessionId;
      await db.insert(tableMeasurement, map);
    } catch (e) {
      AppLogger.error(
        'Error inserting measurement',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  Future<List<Measurement>> getMeasurements(String sessionId) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableMeasurement,
        where: '$colSessionId3 = ?',
        whereArgs: [sessionId],
        orderBy: '$colTimestamp2 ASC',
      );

      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error(
        'Error getting measurements',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  // Utility methods

  Future<int> getSessionCount() async {
    try {
      final db = await database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableSession');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      AppLogger.error(
        'Error getting session count',
        tag: 'DatabaseService',
        exception: e,
      );
      return 0;
    }
  }

  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(tableMeasurement);
      await db.delete(tableGpsPoint);
      await db.delete(tableSyncQueue);
      await db.delete(tableSession);
      AppLogger.warning('All database data cleared', tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error clearing database',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  // CRUD Operations para Sync Queue

  /// Insert a session into the sync queue
  Future<void> insertSyncQueue(String sessionId) async {
    try {
      final db = await database;
      await db.insert(
        tableSyncQueue,
        {
          colSyncSessionId: sessionId,
          colSyncTimestamp: DateTime.now().millisecondsSinceEpoch,
          colSyncStatus: SyncStatus.pending.name,
          colSyncRetryCount: 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      AppLogger.debug('Added to sync queue: $sessionId',
          tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error inserting into sync queue',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Get all pending sync queue items
  Future<List<SyncQueue>> getSyncQueue() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableSyncQueue,
        where: '$colSyncStatus != ?',
        whereArgs: [SyncStatus.completed.name],
        orderBy: '$colSyncTimestamp ASC',
      );

      return maps.map((map) => SyncQueue.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error(
        'Error getting sync queue',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Get a specific sync queue item
  Future<SyncQueue?> getSyncQueueItem(String sessionId) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableSyncQueue,
        where: '$colSyncSessionId = ?',
        whereArgs: [sessionId],
      );

      if (maps.isEmpty) {
        return null;
      }

      return SyncQueue.fromMap(maps.first);
    } catch (e) {
      AppLogger.error(
        'Error getting sync queue item',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Update sync status and error information
  Future<void> updateSyncStatus(
    String sessionId,
    SyncStatus status,
    String? error,
  ) async {
    try {
      final db = await database;

      // Get current retry count
      final maps = await db.query(
        tableSyncQueue,
        where: '$colSyncSessionId = ?',
        whereArgs: [sessionId],
      );

      int retryCount = 0;
      if (maps.isNotEmpty) {
        retryCount = (maps.first[colSyncRetryCount] as int?) ?? 0;
        if (status == SyncStatus.retry || status == SyncStatus.failed) {
          retryCount++;
        }
      }

      await db.update(
        tableSyncQueue,
        {
          colSyncStatus: status.name,
          colSyncLastError: error,
          colSyncLastAttempt: DateTime.now().millisecondsSinceEpoch,
          colSyncRetryCount: retryCount,
        },
        where: '$colSyncSessionId = ?',
        whereArgs: [sessionId],
      );
      AppLogger.debug(
        'Sync status updated: $sessionId -> ${status.name}',
        tag: 'DatabaseService',
      );
    } catch (e) {
      AppLogger.error(
        'Error updating sync status',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Remove a session from the sync queue
  Future<void> removeSyncQueue(String sessionId) async {
    try {
      final db = await database;
      await db.delete(
        tableSyncQueue,
        where: '$colSyncSessionId = ?',
        whereArgs: [sessionId],
      );
      AppLogger.debug('Removed from sync queue: $sessionId',
          tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error removing from sync queue',
        tag: 'DatabaseService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableSyncQueue '
        'WHERE $colSyncStatus = ?',
        [SyncStatus.pending.name],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      AppLogger.error(
        'Error getting pending sync count',
        tag: 'DatabaseService',
        exception: e,
      );
      return 0;
    }
  }

  Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      AppLogger.info('Database closed', tag: 'DatabaseService');
    } catch (e) {
      AppLogger.error(
        'Error closing database',
        tag: 'DatabaseService',
        exception: e,
      );
    }
  }
}
