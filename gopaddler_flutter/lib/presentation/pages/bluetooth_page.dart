import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../../di/service_locator.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Bluetooth'),
      ),
      body: BlocProvider<BluetoothBloc>.value(
        value: getIt<BluetoothBloc>(),
        child: BlocListener<BluetoothBloc, BluetoothState>(
          listener: (context, state) {
            if (state is BluetoothError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<BluetoothBloc, BluetoothState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<BluetoothBloc>().add(
                                    const RequestBluetoothPermissionsEvent(),
                                  );
                            },
                            icon: const Icon(Icons.vpn_key),
                            label: const Text('Permisos'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<BluetoothBloc>().add(
                                    const StartBluetoothScanEvent(
                                      duration: Duration(seconds: 10),
                                    ),
                                  );
                            },
                            icon: const Icon(Icons.bluetooth_searching),
                            label: const Text('Escanear'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<BluetoothBloc>().add(
                                    const StopBluetoothScanEvent(),
                                  );
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('Detener'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Estado actual
                      _StatusSection(state: state),
                      const SizedBox(height: 24.0),

                      // Lista de dispositivos descubiertos
                      if (state is BluetoothScanning) ...[
                        const Text(
                          'Dispositivos Encontrados',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12.0),
                        _DiscoveredDevicesList(devices: state.discoveries),
                        const SizedBox(height: 24.0),
                      ],

                      // Lista de dispositivos conectados
                      if (state is BluetoothConnected) ...[
                        const Text(
                          'Dispositivos Conectados',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12.0),
                        _ConnectedDevicesList(
                          state: state,
                          onDisconnect: (deviceId) {
                            context.read<BluetoothBloc>().add(
                                  DisconnectDeviceEvent(deviceId),
                                );
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Lectura de sensores
                        if (state.lastHeartRate != null ||
                            state.lastCadence != null) ...[
                          const Divider(),
                          const SizedBox(height: 12.0),
                          const Text(
                            'Lecturas de Sensores',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12.0),
                          if (state.lastHeartRate != null)
                            _SensorCard(
                              icon: Icons.favorite,
                              label: 'Frecuencia Cardíaca',
                              value: '${state.lastHeartRate} bpm',
                              color: Colors.red,
                            ),
                          const SizedBox(height: 8.0),
                          if (state.lastCadence != null)
                            _SensorCard(
                              icon: Icons.sync,
                              label: 'Cadencia',
                              value: '${state.lastCadence} rpm',
                              color: Colors.blue,
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  final BluetoothState state;

  const _StatusSection({required this.state});

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    Color statusColor = Colors.grey;

    if (state is BluetoothInitial) {
      statusText = 'Inicial';
    } else if (state is BluetoothPermissionRequesting) {
      statusText = 'Solicitando permisos...';
      statusColor = Colors.orange;
    } else if (state is BluetoothPermissionGranted) {
      statusText = 'Permisos otorgados';
      statusColor = Colors.green;
    } else if (state is BluetoothPermissionDenied) {
      statusText =
          'Permisos denegados: ${(state as BluetoothPermissionDenied).reason}';
      statusColor = Colors.red;
    } else if (state is BluetoothScanning) {
      statusText =
          'Escaneando... (${(state as BluetoothScanning).discoveries.length} dispositivos)';
      statusColor = Colors.blue;
    } else if (state is BluetoothConnecting) {
      statusText = 'Conectando...';
      statusColor = Colors.orange;
    } else if (state is BluetoothConnected) {
      statusText =
          'Conectado (${(state as BluetoothConnected).connectedDevices.length} dispositivos)';
      statusColor = Colors.green;
    } else if (state is BluetoothDisconnected) {
      statusText = 'Desconectado';
    } else if (state is BluetoothError) {
      statusText = 'Error: ${(state as BluetoothError).message}';
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor,
            child: const Icon(Icons.info, color: Colors.white),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(statusText),
          ),
        ],
      ),
    );
  }
}

class _DiscoveredDevicesList extends StatelessWidget {
  final List<dynamic> devices; // List<DiscoveredDevice>

  const _DiscoveredDevicesList({required this.devices});

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Text('No se encontraron dispositivos');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.devices),
            title: Text(device.name),
            subtitle: Text(device.device.remoteId.str),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('RSSI: ${device.rssi}'),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(device.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${device.device.remoteId.str}'),
                      const SizedBox(height: 8.0),
                      Text('RSSI: ${device.rssi}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<BluetoothBloc>().add(
                              ConnectDeviceEvent(
                                deviceId: device.device.remoteId.str,
                                type: 'heart_rate', // Por defecto FC
                              ),
                            );
                      },
                      child: const Text('Conectar (FC)'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<BluetoothBloc>().add(
                              ConnectDeviceEvent(
                                deviceId: device.device.remoteId.str,
                                type: 'cadence',
                              ),
                            );
                      },
                      child: const Text('Conectar (Cadencia)'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ConnectedDevicesList extends StatelessWidget {
  final BluetoothConnected state;
  final Function(String) onDisconnect;

  const _ConnectedDevicesList({
    required this.state,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (state.connectedDevices.isEmpty) {
      return const Text('No hay dispositivos conectados');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.connectedDevices.length,
      itemBuilder: (context, index) {
        final device = state.connectedDevices[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: Text(device.platformName.isNotEmpty
                ? device.platformName
                : 'Dispositivo ${device.remoteId}'),
            subtitle: Text(device.remoteId.str),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                onDisconnect(device.remoteId.str);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
