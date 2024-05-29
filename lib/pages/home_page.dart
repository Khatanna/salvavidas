import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/db/operation.dart';
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
  bool _sending = false;
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

  _sendSms(String message) async {
    if (_sending) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context)!.sending,
      )));
    }
    ;
    try {
      setState(() {
        _sending = true;
      });
      final location = await Geolocator.getCurrentPosition();
      final textLocation =
          'https://www.google.com/maps?q=${location.latitude},${location.longitude}';

      final contacts = await Operation.getContacts();

      await sendSMS(
          message: "$message: $textLocation",
          recipients: contacts.map((e) => e.phone).toList(),
          sendDirect: true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context)!.successSent,
      )));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context)!.errorSent,
      )));
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.location,
      Permission.contacts,
    ].request();

    _handlePermissionStatus(statuses[Permission.sms], "SMS");
    _handlePermissionStatus(statuses[Permission.location], "ubicación");
    _handlePermissionStatus(statuses[Permission.contacts], "contactos");
  }

  void _handlePermissionStatus(PermissionStatus? status, String permission) {
    if (status == null || status.isDenied) {
      showPermissionDeniedDialog(permission);
    } else if (status.isGranted) {
      print("Permiso de $permission concedido");
    } else {
      print("Permiso de $permission estado: $status");
    }
  }

  void showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permiso $permission denegado"),
          content: Text(
              "Por favor, habilita el permiso de $permission en la configuración de la aplicación."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 5,
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
              ]),
            ],
          ),
        ),
        Flexible(
          flex: 7,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      _sendSms(AppLocalizations.of(context)!.redButtonMessaje),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_red.png'),
                        width: 80,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.redButton,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () => _sendSms(
                      AppLocalizations.of(context)!.yellowButtonMessaje),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_yellow.png'),
                        width: 80,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.yellowButton,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () => _sendSms(
                      AppLocalizations.of(context)!.greenButtonMessaje),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_green.png'),
                        width: 80,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.greenButton,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () =>
                      _sendSms(AppLocalizations.of(context)!.blueButtonMessaje),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/icons/security_blue.png'),
                        width: 80,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.blueButton,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
