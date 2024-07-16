import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermAndConditionsPage extends StatelessWidget {
  const TermAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            AppLocalizations.of(context)!.terms,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
