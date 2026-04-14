import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gopaddler_flutter/data/models/session.dart';

class SessionMap extends StatelessWidget {
  final List<GpsPoint> points;

  const SessionMap({
    Key? key,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text('No GPS data available'),
      );
    }

    // Convertir GpsPoints a LatLng
    final latLngPoints = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Calcular bounds
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat > point.latitude ? point.latitude : minLat;
      maxLat = maxLat < point.latitude ? point.latitude : maxLat;
      minLng = minLng > point.longitude ? point.longitude : minLng;
      maxLng = maxLng < point.longitude ? point.longitude : maxLng;
    }

    return FlutterMap(
      options: MapOptions(
        bounds: LatLngBounds(
          LatLng(minLat - 0.001, minLng - 0.001),
          LatLng(maxLat + 0.001, maxLng + 0.001),
        ),
        boundsOptions: const FitBoundsOptions(
          padding: EdgeInsets.all(100),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gopaddler.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: latLngPoints,
              strokeWidth: 3,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Marker inicio (verde)
            Marker(
              point: latLngPoints.first,
              width: 40,
              height: 40,
              builder: (ctx) => const Icon(
                Icons.location_on,
                color: Colors.green,
                size: 30,
              ),
            ),
            // Marker fin (rojo)
            Marker(
              point: latLngPoints.last,
              width: 40,
              height: 40,
              builder: (ctx) => const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
