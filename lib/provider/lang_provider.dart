import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');
  late SharedPreferences _prefs;
  Locale get locale => _locale;

  LangProvider() {
    _loadLocale();
  }

  _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('languageCode') == null) {
      _locale = const Locale('es');
      return null;
    }
    _locale = Locale(_prefs.getString('languageCode')!);
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }
    if (_locale == locale) {
      return;
    }

    _locale = locale;

    await _prefs.setString('languageCode', locale.languageCode);

    notifyListeners();
  }
}
