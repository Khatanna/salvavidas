import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salvavidas/widgets/buttons.dart';
import 'package:salvavidas/widgets/map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.phone,
      Permission.location,
      Permission.contacts,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    await _handlePermissionStatus(statuses[Permission.sms], "SMS");
    await _handlePermissionStatus(statuses[Permission.phone], "phone");
    await _handlePermissionStatus(statuses[Permission.location], "location");
    await _handlePermissionStatus(statuses[Permission.contacts], "contacts");
    await _handlePermissionStatus(statuses[Permission.bluetooth], "Bluetooth");
    await _handlePermissionStatus(
        statuses[Permission.bluetoothAdvertise], "Bluetooth Advertise");
    await _handlePermissionStatus(
        statuses[Permission.bluetoothConnect], "Bluetooth Connect");
    await _handlePermissionStatus(
        statuses[Permission.bluetoothScan], "Bluetooth Scan");
  }

  Future<void> _handlePermissionStatus(
      PermissionStatus? status, String permission) async {
    if (status == null || status.isDenied) {
      await showPermissionDeniedDialog(permission);
    } else if (status.isGranted) {
      // print("Permiso de $permission concedido");
    } else {
      // print("Permiso de $permission estado: $status");
    }
  }

  Future<void> showPermissionDeniedDialog(String permission) {
    return showDialog(
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
