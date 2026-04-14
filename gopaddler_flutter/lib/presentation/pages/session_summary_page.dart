import 'package:flutter/material.dart';
import 'package:gopaddler_flutter/data/models/session.dart';
import 'package:gopaddler_flutter/presentation/widgets/chart_widgets.dart';
import 'package:gopaddler_flutter/presentation/widgets/session_map.dart';
import 'package:intl/intl.dart';

class SessionSummaryPage extends StatefulWidget {
  final Session session;

  const SessionSummaryPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${(widget.session.totalDistance / 1000).toStringAsFixed(1)} km',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Map'),
            Tab(text: 'Splits'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildChartsTab(),
          _buildMapTab(),
          _buildSplitsTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard('Distancia Total', '${(widget.session.totalDistance / 1000).toStringAsFixed(2)} km'),
          _buildMetricCard('Duración', _formatDuration(widget.session.duration)),
          _buildMetricCard('Velocidad Mín.', '${widget.session.gpsPoints.isNotEmpty ? widget.session.gpsPoints.map((p) => p.speed).reduce((a, b) => a < b ? a : b).toStringAsFixed(1) : 'N/A'} km/h'),
          _buildMetricCard('Velocidad Promedio', '${widget.session.averageSpeed.toStringAsFixed(2)} km/h'),
          _buildMetricCard('Velocidad Máxima', '${widget.session.maxSpeed.toStringAsFixed(2)} km/h'),
          const SizedBox(height: 16),
          Text(
            'Fecha: ${DateFormat('dd MMMM yyyy HH:mm').format(widget.session.startTime)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    final speeds = widget.session.gpsPoints.map((p) => p.speed).toList();
    final times = widget.session.gpsPoints.map((p) => p.timestamp).toList();
    
    final bpms = <int>[];
    for (final measurement in widget.session.measurements) {
      if (measurement.type == 'heartRate' && measurement.unit == 'bpm') {
        bpms.add(measurement.value.toInt());
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SpeedChart(speeds: speeds, times: times),
          const SizedBox(height: 16),
          if (bpms.isNotEmpty)
            HeartRateChart(bpms: bpms, times: times)
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No heart rate data available'),
            ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return SessionMap(points: widget.session.gpsPoints);
  }

  Widget _buildSplitsTab() {
    final splits = _generateSplits();
    return SplitsTable(splits: splits);
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalysisCard(
            'Eficiencia',
            '${widget.session.getEfficiencyScore().toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            'Zona Dominante',
            _getDominantZone(),
            Icons.favorite,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            'HR Promedio',
            _getAvgHeartRate(),
            Icons.favorite,
            Colors.red,
          ),
          const SizedBox(height: 16),
          Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recomendación de Entrenamiento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTrainingRecommendation(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  List<Map<String, dynamic>> _generateSplits() {
    const splitDistance = 1000; // 1 km splits
    final splits = <Map<String, dynamic>>[];
    
    double accumulatedDistance = 0;
    DateTime? splitStartTime;
    int splitNumber = 1;

    for (int i = 0; i < widget.session.gpsPoints.length; i++) {
      if (i == 0) {
        splitStartTime = widget.session.gpsPoints[i].timestamp;
      }

      if (i < widget.session.gpsPoints.length - 1) {
        accumulatedDistance +=
            widget.session.gpsPoints[i].distanceTo(widget.session.gpsPoints[i + 1]);
      }

      if (accumulatedDistance >= splitDistance || i == widget.session.gpsPoints.length - 1) {
        final splitDuration = widget.session.gpsPoints[i].timestamp.difference(splitStartTime!);
        final pace = splitDuration.inSeconds > 0 ? splitDuration.inSeconds / splitDistance * 1000 : 0;

        splits.add({
          'number': splitNumber,
          'duration': splitDuration,
          'distance': accumulatedDistance,
          'pace': pace / 60,
          'heartRate': widget.session.zones.isNotEmpty ? widget.session.zones.first.minBpm : null,
        });

        accumulatedDistance = 0;
        splitStartTime = widget.session.gpsPoints[i].timestamp;
        splitNumber++;
      }
    }

    return splits;
  }

  String _getDominantZone() {
    if (widget.session.zones.isEmpty) return 'N/A';
    final zone = widget.session.zones.reduce((a, b) => a.percentage > b.percentage ? a : b);
    return 'Zone ${zone.zone} (${zone.percentage.toStringAsFixed(1)}%)';
  }

  String _getAvgHeartRate() {
    if (widget.session.zones.isEmpty) return 'N/A bpm';
    int totalBpm = 0;
    for (final zone in widget.session.zones) {
      totalBpm += (zone.minBpm + zone.maxBpm) ~/ 2;
    }
    return '${(totalBpm / widget.session.zones.length).toStringAsFixed(0)} bpm';
  }

  String _getTrainingRecommendation() {
    final efficiency = widget.session.getEfficiencyScore();
    if (efficiency > 80) {
      return 'Sesión muy eficiente. Mantén este ritmo de entrenamiento.';
    } else if (efficiency > 60) {
      return 'Buen desempeño. Trabaja en mantener un ritmo más constante.';
    } else {
      return 'Sesión con variaciones de ritmo. Enfócate en mejorar la consistencia.';
    }
  }
}

