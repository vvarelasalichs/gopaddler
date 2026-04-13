import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class SessionActivePage extends StatefulWidget {
  const SessionActivePage({super.key});

  @override
  State<SessionActivePage> createState() => _SessionActivePageState();
}

class _SessionActivePageState extends State<SessionActivePage> {
  @override
  void initState() {
    super.initState();
    // Solicitar permisos de GPS al cargar la página
    context.read<GpsBloc>().add(const RequestGpsPermissionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión Activa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Abrir menú de opciones
            },
          ),
        ],
      ),
      body: BlocListener<GpsBloc, GpsState>(
        listener: (context, state) {
          if (state is GpsPermissionsDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Permisos GPS denegados: ${state.reason}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GpsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error en GPS: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            if (state is GpsInitial) {
              return const Center(
                child: Text('Inicializando GPS...'),
              );
            } else if (state is GpsPermissionsRequesting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GpsPermissionsDenied) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Permisos GPS denegados\n${state.reason}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            } else if (state is GpsPermissionsGranted) {
              return _buildPermissionsGrantedView(context);
            } else if (state is GpsTracking) {
              return _buildTrackingView(context, state);
            } else if (state is GpsStopped) {
              return _buildStoppedView(context, state);
            } else if (state is GpsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Estado desconocido'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermissionsGrantedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Permisos GPS concedidos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<GpsBloc>().add(
                    const StartGpsTrackingEvent(intervalSeconds: 5),
                  );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Tracking'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingView(BuildContext context, GpsTracking state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.radio_button_on, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'En Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Distancia total (prominente)
                    Text(
                      '${(state.totalDistance / 1000).toStringAsFixed(2)} km',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Distancia Total'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Métricas principales
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Velocidad',
                    value: '${state.speed.toStringAsFixed(1)} m/s',
                    icon: Icons.speed,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Vel. Promedio',
                    value: '${state.averageSpeed.toStringAsFixed(1)} m/s',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Altitud',
                    value: '${state.altitude.toStringAsFixed(1)} m',
                    icon: Icons.terrain,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Precisión',
                    value: '±${state.accuracy.toStringAsFixed(1)} m',
                    icon: Icons.info,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Posición GPS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Posición GPS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${state.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lon: ${state.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contadores
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Puntos GPS',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          state.pointCount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones de control
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GpsBloc>().add(
                            const StopGpsTrackingEvent(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Detener Tracking'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoppedView(BuildContext context, GpsStopped state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tracking Completado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildMetricCard(
                    title: 'Distancia Total',
                    value:
                        '${(state.totalDistance / 1000).toStringAsFixed(2)} km',
                    icon: Icons.route,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricCard(
                    title: 'Velocidad Promedio',
                    value: '${state.averageSpeed.toStringAsFixed(1)} m/s',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricCard(
                    title: 'Puntos Recopilados',
                    value: state.pointCount.toString(),
                    icon: Icons.location_on,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Guardar sesión
                            Navigator.of(context).pop();
                          },
                          child: const Text('Guardar Sesión'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Descartar sesión
                            Navigator.of(context).pop();
                          },
                          child: const Text('Descartar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
