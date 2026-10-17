import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../modello/pianta.dart';

/// Versione dello schema dati che questa versione dell'app sa leggere.
const versioneSchemaSupportata = 1;

/// Dove l'app scarica le schede aggiornate. Il file è generato da
/// scripts/valida.py e tenuto aggiornato sul ramo main del repository.
final urlDatiRemoti = Uri.parse(
  'https://raw.githubusercontent.com/pxcalleg/piantalapp/main/app/assets/piante.json',
);

/// Carica le schede: subito dalla copia nel telefono (offline), poi prova a
/// scaricare la versione più recente e la salva per le prossime aperture.
class ArchivioPiante extends ChangeNotifier {
  ArchivioPiante({http.Client? client, Future<Directory> Function()? cartella})
    : _client = client ?? http.Client(),
      _cartella = cartella ?? getApplicationSupportDirectory;

  final http.Client _client;
  final Future<Directory> Function() _cartella;

  List<Pianta> _piante = const [];
  bool _caricato = false;

  List<Pianta> get piante => _piante;
  bool get caricato => _caricato;

  Future<File> get _fileCache async =>
      File('${(await _cartella()).path}/piante.json');

  /// Legge la copia salvata o, la prima volta, quella inclusa nell'app.
  Future<void> carica() async {
    List<Pianta>? piante;
    try {
      final cache = await _fileCache;
      if (await cache.exists()) {
        piante = leggiPacchetto(await cache.readAsString());
      }
    } catch (e) {
      debugPrint('Copia salvata non leggibile: $e');
    }
    piante ??= leggiPacchetto(
      await rootBundle.loadString('assets/piante.json'),
    );
    _piante = piante ?? const [];
    _caricato = true;
    notifyListeners();
  }

  /// Scarica le schede aggiornate. Restituisce true se sono cambiate.
  /// Senza rete, o se il file non è valido, tiene quelle che ha.
  Future<bool> aggiorna() async {
    try {
      final risposta = await _client
          .get(urlDatiRemoti)
          .timeout(const Duration(seconds: 15));
      if (risposta.statusCode != 200) return false;
      final testo = utf8.decode(risposta.bodyBytes);
      final nuove = leggiPacchetto(testo);
      if (nuove == null || nuove.isEmpty) return false;
      await (await _fileCache).writeAsString(testo);
      _piante = nuove;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Aggiornamento schede non riuscito: $e');
      return false;
    }
  }
}

/// Converte il JSON generato da scripts/valida.py. Restituisce null se il
/// pacchetto usa uno schema più recente di quello supportato.
List<Pianta>? leggiPacchetto(String testo) {
  final dati = jsonDecode(testo) as Map<String, dynamic>;
  if ((dati['schema_version'] as int) > versioneSchemaSupportata) return null;
  return (dati['piante'] as List)
      .map((p) => Pianta.fromJson(p as Map<String, dynamic>))
      .toList();
}
