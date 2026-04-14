import 'package:flutter/material.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({Key? key}) : super(key: key);

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  String _selectedSensor = 'accelerometer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Calibration'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sensor selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'accelerometer',
                    label: Text('Accelerometer'),
                  ),
                  ButtonSegment(
                    value: 'gps',
                    label: Text('GPS'),
                  ),
                  ButtonSegment(
                    value: 'heartrate',
                    label: Text('Heart Rate'),
                  ),
                ],
                selected: {_selectedSensor},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedSensor = newSelection.first;
                  });
                },
              ),
            ),

            // Calibration content based on selected sensor
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCalibrationContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationContent() {
    switch (_selectedSensor) {
      case 'accelerometer':
        return _buildAccelerometerCalibration();
      case 'gps':
        return _buildGpsCalibration();
      case 'heartrate':
        return _buildHeartRateCalibration();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAccelerometerCalibration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accelerometer Calibration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Instructions:'),
                const SizedBox(height: 8),
                const Text(
                  '1. Place device on a flat surface\n'
                  '2. Do not move the device\n'
                  '3. Wait for completion',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: const Text('Calibrate Now'),
                    onPressed: () {
                      _showCalibrationProcess('Accelerometer');
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetCalibration('accelerometer');
                    },
                    child: const Text('Reset to Default'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGpsCalibration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GPS Calibration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Instructions:'),
                const SizedBox(height: 8),
                const Text(
                  '1. Go outdoors\n'
                  '2. Allow GPS to acquire signal (1-2 minutes)\n'
                  '3. Stand still during calibration',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text('Calibrate GPS'),
                    onPressed: () {
                      _showCalibrationProcess('GPS');
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetCalibration('gps');
                    },
                    child: const Text('Reset to Default'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateCalibration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heart Rate Calibration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Instructions:'),
                const SizedBox(height: 8),
                const Text(
                  '1. Connect your HR monitor\n'
                  '2. Wear the device correctly\n'
                  '3. Wait for reading to stabilize',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Calibrate HR'),
                    onPressed: () {
                      _showCalibrationProcess('Heart Rate');
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetCalibration('heartrate');
                    },
                    child: const Text('Reset to Default'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCalibrationProcess(String sensorName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Calibrating $sensorName'),
        content: SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Please wait... 0 / 10'),
            ],
          ),
        ),
      ),
    );

    // Simulate calibration process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$sensorName calibration complete'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _resetCalibration(String sensorType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Calibration'),
        content: const Text(
          'Are you sure you want to reset calibration to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calibration reset to default'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
