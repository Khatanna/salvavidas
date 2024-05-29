import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class LangProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  LangProvider() {
    askGpsandSmss();
  }

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }

  Future<void> askGpsandSmss() async {
    // switch (status) {
    //   case PermissionStatus.granted:
    //     permisionIsGranted = true;
    //     getUserPosition();
    //     break;
    //   case PermissionStatus.denied:
    //   case PermissionStatus.restricted:
    //   case PermissionStatus.limited:
    //   case PermissionStatus.permanentlyDenied:
    //   case PermissionStatus.provisional:
    //     permisionIsGranted = false;
    //     openAppSettings();
    // }
  }
}
