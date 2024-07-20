import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/constants.dart';
import 'package:salvavidas/l10n/l10n.dart';
import 'package:salvavidas/provider/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _customNumberController = TextEditingController();
  final _customMessageController = TextEditingController();
  String _messageStrategy = "sms";
  void _saveSettings() async {
    final snackContext = ScaffoldMessenger.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customNumber', _customNumberController.text);
    await prefs.setString('blueButtonMessage', _customMessageController.text);
    await prefs.setString('messageStrategy', _messageStrategy);
    snackContext.showSnackBar(
      const SnackBar(
        content: Text("Guardado"),
      ),
    );
  }

  void _loadFields() async {
    final prefs = await SharedPreferences.getInstance();

    _customNumberController.text = prefs.getString('customNumber') ?? '';
    _customMessageController.text = prefs.getString('blueButtonMessage') ?? '';
    setState(() {
      _messageStrategy = prefs.getString('messageStrategy') ?? 'sms';
    });
  }

  @override
  void initState() {
    super.initState();

    _loadFields();
  }

  @override
  Widget build(BuildContext context) {
    String value = AppLocalizations.of(context)?.localeName ?? 'es';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
        onPressed: _saveSettings,
        child: const Icon(
          Icons.save,
          size: 30,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(
                    Icons.language,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.settingsLanguage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ]),
                DropdownButton<String>(
                  value: value,
                  onChanged: (value) async {
                    if (value != null) {
                      Provider.of<LangProvider>(context, listen: false)
                          .setLocale(Locale(value));
                    }
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  hint: Text(
                    AppLocalizations.of(context)!.hintLanguageDropdown,
                  ),
                  items: L10n.all
                      .map(
                        (locale) => DropdownMenuItem(
                          value: locale.languageCode,
                          child: Text(
                            dictionaryFromCountry[locale.languageCode]!,
                          ),
                        ),
                      )
                      .toList(),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.whatsapp,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _messageStrategy == 'whatsapp',
                onChanged: (value) {
                  setState(() {
                    _messageStrategy = value ? 'whatsapp' : 'sms';
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.customNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ]),
            TextField(
              controller: _customNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.customNumber,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.message,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.settingsCustomMessage,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: _customMessageController,
                      maxLines: 5,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.settingsCustomMessage,
                      ),
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
