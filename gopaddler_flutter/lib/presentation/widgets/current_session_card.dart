import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gopaddler_flutter/presentation/bloc/session/session_bloc.dart';

class CurrentSessionCard extends StatelessWidget {
  final VoidCallback onStartTapped;
  final VoidCallback onContinueTapped;

  const CurrentSessionCard({
    Key? key,
    required this.onStartTapped,
    required this.onContinueTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final isActive = state is SessionInProgress && !state.isPaused;
        final session = isActive ? (state as SessionInProgress).session : null;

        return Card(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: isActive && session != null
                ? _buildActiveSession(context, session, state as SessionInProgress)
                : _buildInactiveSession(context),
          ),
        );
      },
    );
  }

  Widget _buildActiveSession(BuildContext context, dynamic session, SessionInProgress state) {
    final duration = state.elapsed;
    final formatted = _formatDuration(duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sesión Activa',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          formatted,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<SessionBloc>().add(const PauseSessionEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Pausar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onContinueTapped,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Resumir'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInactiveSession(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onStartTapped,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Iniciar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
