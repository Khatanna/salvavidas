import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
      stream: FlutterBluePlus.adapterState,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          if (state == BluetoothAdapterState.on) {
            return Scaffold(
              body: FutureBuilder(
                future: FlutterBluePlus.bondedDevices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final bondedDevices = snapshot.data as List<BluetoothDevice>;
                  if (bondedDevices.isEmpty) {
                    return Center(
                      child:
                          Text(AppLocalizations.of(context)!.notFoundDevices),
                    );
                  }
                  return ListView.builder(
                    itemCount: bondedDevices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(bondedDevices[index].platformName.isEmpty
                            ? AppLocalizations.of(context)!.unknown
                            : bondedDevices[index].platformName),
                        subtitle: Text(bondedDevices[index].advName.isEmpty
                            ? AppLocalizations.of(context)!.unknown
                            : bondedDevices[index].advName),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await bondedDevices[index].connect();
                            await bondedDevices[index].createBond();
                            await bondedDevices[index].discoverServices();
                            await bondedDevices[index].requestMtu(512);

                            await bondedDevices[index]
                                .connect(autoConnect: true, mtu: null);

                            await bondedDevices[index]
                                .connectionState
                                .where((val) =>
                                    val == BluetoothConnectionState.connected)
                                .first;

                            await bondedDevices[index].disconnect();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.connect,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bluetoothOff,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await FlutterBluePlus.turnOn();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.turnOn,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }
}
