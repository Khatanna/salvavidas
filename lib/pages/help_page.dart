import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();

    try {
      final dir = await getTemporaryDirectory();

      File file = File("${dir.path}/$filename");
      final data = await rootBundle.load(asset);

      final bytes = data.buffer.asUint8List();

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    return Scaffold(
      body: FutureBuilder<File>(
        future: fromAsset('assets/files/$myLocale.pdf', '$myLocale.pdf'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.data != null) {
            final path = snapshot.data!.path;
            // Logger().i('PDF path: $path');
            return PDFView(
              filePath: path,
              fitPolicy: FitPolicy.BOTH,
              fitEachPage: true,
            );
          }

          return const Text('Error: No se pudo cargar el archivo PDF');
        },
      ),
    ); // SfPdfViewer.asset('assets/files/AYUDA ESPAÑOL SALVAVIDAS APP.pdf');
  }
}
