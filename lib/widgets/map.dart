import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      )),
      builder: (context, snapshot) {
        final position = snapshot.data;

        if (position != null) {
          final point = LatLng(position.latitude, position.longitude);
          return FlutterMap(
            options: MapOptions(
              maxZoom: 15.0,
              initialCenter: point,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: [
                Marker(
                    point: point,
                    child: const Icon(
                      Icons.location_on,
                      color: Color.fromRGBO(136, 39, 39, 1),
                      size: 35,
                    ))
              ]),
            ],
          );
        }

        return const Center(
          child: Image(
            image: AssetImage('assets/loaders/map_loading.gif'),
          ),
        );
      },
    );
  }
}
