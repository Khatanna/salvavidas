import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:salvavidas/db/operation.dart';
import 'package:salvavidas/models/Contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:salvavidas/models/Button.dart';

class Buttons extends StatefulWidget {
  const Buttons({super.key});

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  final quickActions = const QuickActions();

  Future<String> _getMessage(Button button, SharedPreferences prefs) async {
    final translates = AppLocalizations.of(context);

    switch (button) {
      case Button.red:
        return translates!.redButtonMessaje;
      case Button.yellow:
        return translates!.yellowButtonMessaje;
      case Button.green:
        return translates!.greenButtonMessaje;
      case Button.blue:
        {
          final message = prefs.getString('blueButtonMessage');

          if (message != null && message.isNotEmpty) {
            return message;
          }

          return translates!.blueButtonMessaje;
        }
    }
  }

  _sendSms(
    Button button,
    SharedPreferences prefs,
  ) async {
    final translates = AppLocalizations.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    try {
      List<Contact> contacts = await Operation.getContacts(button: button);
      final recipients = contacts.map((e) => e.phone).toList();

      if (recipients.isEmpty) {
        scaffold.showSnackBar(SnackBar(
            content: Text(
          translates!.emptyContacts,
        )));
        return;
      }

      if (button == Button.red) {
        final auxNumber = prefs.getString('customNumber');

        if (auxNumber != null) {
          recipients.add(auxNumber);
        }
      }

      final location = await Geolocator.getCurrentPosition();
      final textLocation =
          'https://www.google.com/maps?q=${location.latitude},${location.longitude}';

      final message = await _getMessage(button, prefs);
      final messageStrategy = prefs.getString('messageStrategy') ?? 'sms';
      await sendSMS(
        message: "$message: $textLocation",
        recipients: recipients,
        sendDirect: true,
      );
      if (messageStrategy == 'whatsapp') {
        for (var i = 0; i < recipients.length; i++) {
          final element = recipients[i];
          launchUrlString(
            'https://wa.me/$element?text=$message: $textLocation',
          );
        }
      }

      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            translates!.successSent,
          ),
        ),
      );
    } catch (e) {
      Logger().e(e);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            translates!.errorSent,
          ),
        ),
      );
    }
  }

  Future<void> _loadQuickActions() async {
    final prefs = await SharedPreferences.getInstance();
    quickActions.setShortcutItems(
      <ShortcutItem>[
        const ShortcutItem(
          type: 'red',
          localizedTitle: 'Botón Rojo',
          icon: 'security_red',
        ),
        const ShortcutItem(
          type: 'yellow',
          localizedTitle: 'Botón Amarillo',
          icon: 'security_yellow',
        ),
        const ShortcutItem(
          type: 'green',
          localizedTitle: 'Botón Verde',
          icon: 'security_green',
        ),
        const ShortcutItem(
          type: 'blue',
          localizedTitle: 'Botón Azul',
          icon: 'security_blue',
        ),
      ],
    );

    quickActions.initialize((type) {
      if (type == 'red') {
        _sendSms(Button.red, prefs);
      } else if (type == 'yellow') {
        _sendSms(Button.yellow, prefs);
      } else if (type == 'green') {
        _sendSms(Button.green, prefs);
      } else if (type == 'blue') {
        _sendSms(Button.blue, prefs);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuickActions();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // if (!snapshot.hasData) {
          //   return const Center(
          //     child: Text('Error al cargar las preferencias'),
          //   );
          // }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _sendSms(Button.red, snapshot.data!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image: const AssetImage('assets/icons/security_red.png'),
                      height: screenHeight * 0.1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.redButton,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              InkWell(
                onTap: () => _sendSms(Button.yellow, snapshot.data!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image:
                          const AssetImage('assets/icons/security_yellow.png'),
                      height: screenHeight * 0.1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.yellowButton,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              InkWell(
                onTap: () => _sendSms(Button.green, snapshot.data!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image:
                          const AssetImage('assets/icons/security_green.png'),
                      height: screenHeight * 0.1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.greenButton,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              InkWell(
                onTap: () => _sendSms(Button.blue, snapshot.data!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image: const AssetImage('assets/icons/security_blue.png'),
                      height: screenHeight * 0.1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.blueButton,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
