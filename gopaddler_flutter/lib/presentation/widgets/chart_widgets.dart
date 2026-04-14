import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpeedChart extends StatelessWidget {
  final List<double> speeds;
  final List<DateTime> times;

  const SpeedChart({
    Key? key,
    required this.speeds,
    required this.times,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (speeds.isEmpty || times.isEmpty) {
      return const Center(
        child: Text('No speed data available'),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < speeds.length; i++) {
      spots.add(FlSpot(i.toDouble(), speeds[i]));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speed Chart',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 30,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeartRateChart extends StatelessWidget {
  final List<int> bpms;
  final List<DateTime> times;
  final int maxHeartRate;

  const HeartRateChart({
    Key? key,
    required this.bpms,
    required this.times,
    this.maxHeartRate = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bpms.isEmpty || times.isEmpty) {
      return const Center(
        child: Text('No heart rate data available'),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < bpms.length; i++) {
      spots.add(FlSpot(i.toDouble(), bpms[i].toDouble()));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heart Rate Chart',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 40,
                maxY: (maxHeartRate).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplitsTable extends StatelessWidget {
  final List<Map<String, dynamic>> splits;

  const SplitsTable({
    Key? key,
    required this.splits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Tiempo')),
            DataColumn(label: Text('Dist (km)')),
            DataColumn(label: Text('Ritmo (m/km)')),
            DataColumn(label: Text('HR (bpm)')),
          ],
          rows: splits
              .map(
                (split) => DataRow(
                  cells: [
                    DataCell(Text('${split['number']}')),
                    DataCell(Text(_formatDuration(split['duration']))),
                    DataCell(Text('${(split['distance'] / 1000).toStringAsFixed(2)}')),
                    DataCell(Text('${split['pace']?.toStringAsFixed(1) ?? 'N/A'}')),
                    DataCell(Text('${split['heartRate'] ?? 'N/A'}')),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
