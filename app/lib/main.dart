import 'package:flutter/material.dart';

import 'dati/archivio_piante.dart';
import 'schermate/elenco_piante.dart';

void main() {
  final archivio = ArchivioPiante();
  runApp(PiantalApp(archivio: archivio));
  archivio.carica().then((_) => archivio.aggiorna());
}

class PiantalApp extends StatelessWidget {
  const PiantalApp({super.key, required this.archivio});

  final ArchivioPiante archivio;

  @override
  Widget build(BuildContext context) {
    const seme = Color(0xFF3B7D4F);
    return MaterialApp(
      title: 'PiantalAPP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seme, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: seme,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: ElencoPiante(archivio: archivio),
    );
  }
}
