import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:gopaddler_flutter/presentation/bloc/session/session_bloc.dart';
import 'package:gopaddler_flutter/data/models/session.dart';
import 'package:gopaddler_flutter/data/services/database_service.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'canoeing', child: Text('Paddling')),
                DropdownMenuItem(value: 'cycling', child: Text('Cycling')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'Todos';
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(seconds: 1));
              },
              child: _buildSessionsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return FutureBuilder<List<Session>>(
      future: GetIt.instance<DatabaseService>().getAllSessions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No sessions found'));
        }

        final allSessions = snapshot.data!;
        final sessions = _selectedFilter == 'Todos'
            ? allSessions
            : allSessions.where((s) => s.sportType == _selectedFilter).toList();

        if (sessions.isEmpty) {
          return const Center(child: Text('No sessions found'));
        }

        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Slidable(
              key: Key(session.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await GetIt.instance<DatabaseService>().deleteSession(session.id);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  context.go('/session/summary', extra: session);
                },
                child: SessionListTile(session: session),
              ),
            );
          },
        );
      },
    );
  }
}

class SessionListTile extends StatelessWidget {
  final Session session;

  const SessionListTile({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = (session.totalDistance / 1000).toStringAsFixed(1);
    final duration = _formatDuration(session.duration);
    final avgSpeed = session.averageSpeed.toStringAsFixed(1);
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(session.startTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: session.sportType == 'canoeing' ? Colors.blue : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            session.sportType == 'canoeing'
                ? Icons.directions_boat
                : Icons.two_wheeler,
            color: Colors.white,
          ),
        ),
        title: Text(
          '$distance km - ${session.sportType}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '$duration • $avgSpeed km/h avg\n$dateStr',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'share',
              child: Text('Share'),
            ),
          ],
          onSelected: (value) {
            if (value == 'share') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            }
          },
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes}m';
    }
    return '${minutes}m';
  }
}

