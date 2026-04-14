import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gopaddler_flutter/presentation/bloc/session/session_bloc.dart';
import 'package:gopaddler_flutter/presentation/widgets/stat_card.dart';
import 'package:gopaddler_flutter/presentation/widgets/current_session_card.dart';
import 'package:gopaddler_flutter/data/services/database_service.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseService _dbService;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _dbService = GetIt.instance<DatabaseService>();
    _statsFuture = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final allSessions = await _dbService.getAllSessions();
    final sessions = allSessions
        .where((s) => s.startTime.isAfter(firstDayOfMonth) && s.startTime.isBefore(now))
        .toList();

    double totalDistance = 0;
    double avgHeartRate = 0;
    double maxSpeed = 0;
    int hrCount = 0;

    for (final session in sessions) {
      totalDistance += session.totalDistance;
      maxSpeed = session.maxSpeed > maxSpeed ? session.maxSpeed : maxSpeed;
      
      if (session.zones.isNotEmpty) {
        for (final zone in session.zones) {
          avgHeartRate += zone.minBpm + zone.maxBpm / 2;
          hrCount++;
        }
      }
    }

    return {
      'totalDistance': (totalDistance / 1000).toStringAsFixed(1),
      'sessionsCount': sessions.length.toString(),
      'avgHeartRate': (hrCount > 0 ? (avgHeartRate / hrCount) : 0).toStringAsFixed(0),
      'maxSpeed': maxSpeed.toStringAsFixed(1),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoPaddler'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CurrentSessionCard(
                onStartTapped: () {
                  context.read<SessionBloc>().add(const StartSessionEvent(sportType: 'canoeing'));
                  Navigator.of(context).pushNamed('/session-active');
                },
                onContinueTapped: () {
                  Navigator.of(context).pushNamed('/session-active');
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Stats - ${DateFormat('MMMM').format(DateTime.now())}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: Text('Error loading stats')),
                  );
                }

                final stats = snapshot.data ?? {};
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        StatCard(
                          title: 'Distancia (km)',
                          value: stats['totalDistance'].toString(),
                          icon: Icons.route,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          title: 'Sesiones',
                          value: stats['sessionsCount'].toString(),
                          icon: Icons.calendar_today,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          title: 'HR Promedio',
                          value: '${stats['avgHeartRate']} bpm',
                          icon: Icons.favorite,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          title: 'Vel. Máxima',
                          value: '${stats['maxSpeed']} km/h',
                          icon: Icons.speed,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/session/active');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Start New Session'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<SessionBloc>().add(const StartSessionEvent(sportType: 'canoeing'));
          Navigator.of(context).pushNamed('/session-active');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
