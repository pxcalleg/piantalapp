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
    final incluse =
        leggiPacchetto(await rootBundle.loadString('assets/piante.json')) ??
        const [];
    if (!kIsWeb) {
      try {
        final cache = await _fileCache;
        if (await cache.exists()) {
          piante = leggiPacchetto(await cache.readAsString());
        }
      } catch (e) {
        debugPrint('Copia salvata non leggibile: $e');
      }
    }
    // Dopo un aggiornamento dell'app le schede incluse possono essere più
    // recenti di quelle salvate: si tiene la versione più nuova di ciascuna.
    _piante = unisci(incluse, piante ?? const []);
    _caricato = true;
    notifyListeners();
  }

  /// Scarica le schede aggiornate. Restituisce true se ne è arrivata qualcuna
  /// nuova o più recente.
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
      // Sul web il browser fa già da cache; il file locale serve solo sul telefono.
      if (!kIsWeb) await (await _fileCache).writeAsString(testo);
      final unite = unisci(_piante, nuove);
      final cambiate =
          unite.length != _piante.length ||
          Iterable.generate(unite.length)
              .any((i) => !identical(unite[i], _piante[i]));
      _piante = unite;
      if (cambiate) notifyListeners();
      return cambiate;
    } catch (e) {
      debugPrint('Aggiornamento schede non riuscito: $e');
      return false;
    }
  }
}

/// Unisce due elenchi di schede tenendo, per ogni pianta, quella con la data
/// `aggiornato` più recente; a parità di data vince [attuali].
List<Pianta> unisci(List<Pianta> attuali, List<Pianta> nuove) {
  final perId = {for (final p in attuali) p.id: p};
  for (final p in nuove) {
    final vecchia = perId[p.id];
    if (vecchia == null || p.aggiornato.compareTo(vecchia.aggiornato) > 0) {
      perId[p.id] = p;
    }
  }
  return perId.values.toList();
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
