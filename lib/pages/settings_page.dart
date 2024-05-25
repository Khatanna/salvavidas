import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/provider/lang_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _value = 'es';

  _getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('language');
    if (language != null) {
      setState(() {
        _value = language;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DropdownButton<String>(
            value: _value,
            onChanged: (value) async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              prefs.setString('language', value!);
              if (!context.mounted) return;
              Provider.of<LangProvider>(context, listen: false)
                  .setLocale(Locale(value));
              setState(() {
                _value = value;
              });
            },
            icon: const Icon(Icons.arrow_drop_down),
            hint: Text(
              AppLocalizations.of(context)!.hintLanguageDropdown,
            ),
            items: const [
              DropdownMenuItem(
                value: 'es',
                child: Text('Español'),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
