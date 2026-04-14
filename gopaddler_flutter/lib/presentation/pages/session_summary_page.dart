import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gopaddler_flutter/data/models/session.dart';
import 'package:gopaddler_flutter/domain/services/analytics_service.dart';
import 'package:gopaddler_flutter/domain/models/session_analytics.dart';
import 'package:gopaddler_flutter/presentation/widgets/chart_widgets.dart';
import 'package:gopaddler_flutter/presentation/widgets/session_map.dart';
import 'package:intl/intl.dart';

class SessionSummaryPage extends StatefulWidget {
  final Session session;
  final Session? previousSession;

  const SessionSummaryPage({
    Key? key,
    required this.session,
    this.previousSession,
  }) : super(key: key);

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnalyticsService _analyticsService;
  SessionAnalytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _analyticsService = GetIt.instance<AnalyticsService>();
    _generateAnalytics();
  }

  Future<void> _generateAnalytics() async {
    try {
      final analytics = _analyticsService.analyzeSession(
        widget.session,
        widget.previousSession,
        200, // Default max HR
      );
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing session: $e')),
        );
      }
    }
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
          '${(_analytics?.totalDistance ?? widget.session.totalDistance / 1000).toStringAsFixed(1)} km',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
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
          _buildMetricCard('Distance', '${(_analytics?.totalDistance ?? 0).toStringAsFixed(2)} km'),
          _buildMetricCard('Duration', _formatDuration(_analytics?.totalTime ?? widget.session.duration)),
          _buildMetricCard('Avg Speed', '${(_analytics?.averageSpeed ?? 0).toStringAsFixed(2)} km/h'),
          _buildMetricCard('Max Speed', '${(_analytics?.maxSpeed ?? 0).toStringAsFixed(2)} km/h'),
          _buildMetricCard('Efficiency', '${(_analytics?.efficiencyScore ?? 0).toStringAsFixed(1)}%'),
          if (_analytics?.averageHeartRate != null) ...[
            const SizedBox(height: 12),
            _buildMetricCard('Avg Heart Rate', '${_analytics!.averageHeartRate} bpm'),
            _buildMetricCard('Max Heart Rate', '${_analytics!.maxHeartRate ?? 'N/A'} bpm'),
          ],
          if (_analytics?.elevationGain != null) ...[
            const SizedBox(height: 12),
            _buildMetricCard('Elevation Gain', '${_analytics!.elevationGain} m'),
            _buildMetricCard('Elevation Loss', '${_analytics!.elevationLoss} m'),
          ],
          const SizedBox(height: 16),
          Text(
            'Date: ${DateFormat('dd MMMM yyyy HH:mm').format(widget.session.startTime)}',
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.session.splits.length,
      itemBuilder: (context, index) {
        final split = widget.session.splits[index];
        final isMaxEffort = _analytics?.maxEfforts?.any((e) => e.number == index + 1) ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: isMaxEffort ? 4 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isMaxEffort ? Colors.red : Colors.blue,
              child: Text(
                split.number.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('Split ${split.number}${split.name != null ? ' - ${split.name}' : ''}'),
            subtitle: Text(
              '${split.formatTime()} | ${split.distance.toStringAsFixed(2)} km | ${split.averageSpeed.toStringAsFixed(2)} km/h',
            ),
            trailing: isMaxEffort
                ? const Tooltip(
                    message: 'Max Effort',
                    child: Icon(Icons.flash_on, color: Colors.red),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab() {
    if (_analytics == null) {
      return const Center(child: Text('No analytics available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Efficiency Badge
          _buildEfficiencyCard(),
          const SizedBox(height: 16),

          // Max Efforts
          if (_analytics!.maxEfforts != null && _analytics!.maxEfforts!.isNotEmpty) ...[
            Text('Max Efforts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._analytics!.maxEfforts!.map((effort) => _buildMaxEffortCard(effort)),
            const SizedBox(height: 16),
          ],

          // Zone Distribution
          if (_analytics!.zoneDistribution != null && _analytics!.zoneDistribution!.isNotEmpty) ...[
            Text('Heart Rate Zone Distribution', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._analytics!.zoneDistribution!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          minHeight: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${entry.value.toStringAsFixed(1)}%', textAlign: TextAlign.right),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Comparison with Previous
          if (_analytics!.comparisonWithPrevious != null) ...[
            _buildComparisonCard(_analytics!.comparisonWithPrevious!),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (_analytics!.recommendations != null && _analytics!.recommendations!.isNotEmpty) ...[
            Text('Recommendations', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _analytics!.recommendations!
                      .map((rec) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(rec)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    final badge = _analytics!.getEfficiencyBadge();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Efficiency Score', style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badge.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${_analytics!.efficiencyScore.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: badge.color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How consistent your pace was during this session',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxEffortCard(MaxEffort effort) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.flash_on,
          color: Colors.red,
        ),
        title: Text('Max Effort #${effort.number}'),
        subtitle: Text(
          '${effort.speed.toStringAsFixed(2)} km/h | ${effort.distance.toStringAsFixed(2)} km',
        ),
        trailing: Text(
          effort.duration.inMinutes.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildComparisonCard(SessionComparison comparison) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Comparison with Previous Session',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(
                  comparison.trendEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comparison.getTrendDescription()),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'Speed',
              comparison.speedDifference,
              'km/h',
            ),
            _buildComparisonRow(
              'Distance',
              comparison.distanceDifference,
              'km',
            ),
            _buildComparisonRow(
              'Efficiency',
              comparison.efficiencyDifference,
              '%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, double value, String unit) {
    final isPositive = value >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${value.toStringAsFixed(2)} $unit',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}

