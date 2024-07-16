import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salvavidas/widgets/buttons.dart';
import 'package:salvavidas/widgets/map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.location,
      Permission.contacts,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request();

    _handlePermissionStatus(statuses[Permission.sms], "SMS");
    _handlePermissionStatus(statuses[Permission.location], "location");
    _handlePermissionStatus(statuses[Permission.contacts], "contacts");
    _handlePermissionStatus(statuses[Permission.bluetooth], "Bluetooth");
    _handlePermissionStatus(
        statuses[Permission.bluetoothAdvertise], "Bluetooth Advertise");
    _handlePermissionStatus(
        statuses[Permission.bluetoothConnect], "Bluetooth Connect");
    _handlePermissionStatus(
        statuses[Permission.bluetoothScan], "Bluetooth Scan");
  }

  void _handlePermissionStatus(PermissionStatus? status, String permission) {
    if (status == null || status.isDenied) {
      showPermissionDeniedDialog(permission);
    } else if (status.isGranted) {
      // print("Permiso de $permission concedido");
    } else {
      // print("Permiso de $permission estado: $status");
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
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _requestPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            const Flexible(
              flex: 4,
              child: MapWidget(),
            ),
            Flexible(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: const Buttons(),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                width: screenWidth,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.disclaimer,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
