import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/provider/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _latitude = 0;
  double _longitude = 0;
  final MapController _mapController = MapController();

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Servicio de localización desactivado');
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Permiso de localización denegado por siempre');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Permiso de localización denegado');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('language');
    if (language != null) {
      if (!context.mounted) return;
      Provider.of<LangProvider>(context, listen: false)
          .setLocale(Locale(language));
    }
  }

  @override
  void initState() {
    super.initState();

    _getPreferences();

    _getCurrentLocation().then((Position position) {
      // _mapController.move(LatLng(position.latitude, position.longitude), 15);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(51.5, -0.09),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(markers: [
                  Marker(
                      point: LatLng(_latitude, _longitude),
                      child: const Icon(
                        Icons.location_on,
                        color: Color.fromRGBO(136, 39, 39, 1),
                        size: 35,
                      ))
                ])
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    // try {
                    //   await sendSMS(
                    //       message: "mensaje de prueba",
                    //       recipients: ['+59176552421'],
                    //       sendDirect: true);
                    //   if (!context.mounted) return;
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("Se envio el mensaje")));
                    // } catch (e) {
                    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //       content: Text("No se logro enviar el mensaje")));
                    // }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_red.png'),
                        width: 85,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.redButton,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Se envio el mensaje")));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_yellow.png'),
                        width: 85,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.yellowButton,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Se envio el mensaje")));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_green.png'),
                        width: 85,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.greenButton,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Se envio el mensaje")));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_blue.png'),
                        width: 85,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.blueButton,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
