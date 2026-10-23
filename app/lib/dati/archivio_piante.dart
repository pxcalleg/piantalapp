import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../modello/fungo.dart';
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
  List<Fungo> _funghi = const [];
  bool _caricato = false;

  List<Pianta> get piante => _piante;
  List<Fungo> get funghi => _funghi;
  bool get caricato => _caricato;

  Future<File> get _fileCache async =>
      File('${(await _cartella()).path}/piante.json');

  /// Legge la copia salvata o, la prima volta, quella inclusa nell'app.
  Future<void> carica() async {
    List<Pianta>? piante;
    List<Fungo>? funghi;
    final pacchetto = await rootBundle.loadString('assets/piante.json');
    final incluse = leggiPacchetto(pacchetto) ?? const [];
    final funghiInclusi = leggiFunghi(pacchetto) ?? const [];
    if (!kIsWeb) {
      try {
        final cache = await _fileCache;
        if (await cache.exists()) {
          final salvato = await cache.readAsString();
          piante = leggiPacchetto(salvato);
          funghi = leggiFunghi(salvato);
        }
      } catch (e) {
        debugPrint('Copia salvata non leggibile: $e');
      }
    }
    // Dopo un aggiornamento dell'app le schede incluse possono essere più
    // recenti di quelle salvate: si tiene la versione più nuova di ciascuna.
    _piante = unisci(incluse, piante ?? const []);
    _funghi = unisci(funghiInclusi, funghi ?? const []);
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
      final funghi = unisci(_funghi, leggiFunghi(testo) ?? const <Fungo>[]);
      final cambiate = _diverse(unite, _piante) || _diverse(funghi, _funghi);
      _piante = unite;
      _funghi = funghi;
      if (cambiate) notifyListeners();
      return cambiate;
    } catch (e) {
      debugPrint('Aggiornamento schede non riuscito: $e');
      return false;
    }
  }
}

bool _diverse(List<Scheda> a, List<Scheda> b) =>
    a.length != b.length ||
    Iterable.generate(a.length).any((i) => !identical(a[i], b[i]));

/// Unisce due elenchi di schede tenendo, per ogni pianta o fungo, quella con
/// la data `aggiornato` più recente; a parità di data vince [attuali].
List<T> unisci<T extends Scheda>(List<T> attuali, List<T> nuove) {
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

/// I funghi dello stesso pacchetto. I pacchetti precedenti alla sezione
/// Funghi non hanno la voce e danno un elenco vuoto.
List<Fungo>? leggiFunghi(String testo) {
  final dati = jsonDecode(testo) as Map<String, dynamic>;
  if ((dati['schema_version'] as int) > versioneSchemaSupportata) return null;
  return ((dati['funghi'] as List?) ?? const [])
      .map((f) => Fungo.fromJson(f as Map<String, dynamic>))
      .toList();
}
