import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'pianta.dart';

/// Chiave del servizio Pl@ntNet, passata al momento della compilazione con
/// `--dart-define=PLANTNET_API_KEY=...` (in CI viene dal secret omonimo).
/// Vuota nelle build locali: il riconoscimento resta spento.
const chiavePlantNet = String.fromEnvironment('PLANTNET_API_KEY');

/// Sito autorizzato per la chiave nelle impostazioni di Pl@ntNet.
const origineApp = 'https://pxcalleg.github.io';

/// Una specie proposta dal riconoscimento, con la sua probabilità (0-1).
class Ipotesi {
  const Ipotesi({
    required this.nomeScientifico,
    required this.punteggio,
    this.nomiComuni = const [],
    this.famiglia,
  });

  final String nomeScientifico;
  final double punteggio;
  final List<String> nomiComuni;
  final String? famiglia;

  int get percentuale => (punteggio * 100).round();
}

/// Il servizio non ha risposto come previsto; [messaggio] è per l'utente.
class ErroreRiconoscimento implements Exception {
  const ErroreRiconoscimento(this.messaggio);

  final String messaggio;

  @override
  String toString() => messaggio;
}

/// Legge la risposta di `POST /v2/identify`.
List<Ipotesi> leggiRisposta(Map<String, dynamic> json) => [
  for (final r in (json['results'] as List? ?? const []))
    Ipotesi(
      nomeScientifico:
          (r['species']?['scientificNameWithoutAuthor'] as String?) ?? '',
      punteggio: (r['score'] as num?)?.toDouble() ?? 0,
      nomiComuni: [
        for (final n in (r['species']?['commonNames'] as List? ?? const []))
          n as String,
      ],
      famiglia:
          r['species']?['family']?['scientificNameWithoutAuthor'] as String?,
    ),
].where((i) => i.nomeScientifico.isNotEmpty).toList();

/// Genere e specie in minuscolo, senza cultivar, note tra parentesi e "×".
List<String> _parole(String nome) => nome
    .replaceAll(RegExp(r"'[^']*'|\([^)]*\)"), ' ')
    .replaceAll('×', ' ')
    .toLowerCase()
    .split(RegExp(r'\s+'))
    .where((p) => p.isNotEmpty)
    .take(2)
    .toList();

/// Le schede dell'archivio collegate a una specie riconosciuta: prima quelle
/// della stessa specie, altrimenti quelle dello stesso genere (per esempio
/// tutte le rose per una "Rosa chinensis").
({List<Pianta> stessaSpecie, List<Pianta> stessoGenere}) schedeCollegate(
  List<Pianta> piante,
  Ipotesi ipotesi,
) {
  final cercata = _parole(ipotesi.nomeScientifico);
  if (cercata.isEmpty) return (stessaSpecie: [], stessoGenere: []);
  final stessaSpecie = <Pianta>[];
  final stessoGenere = <Pianta>[];
  for (final p in piante) {
    final nomi = [p.nomeScientifico, ...p.sinonimi].map(_parole);
    if (nomi.any((n) => n.length == 2 && listEquals(n, cercata))) {
      stessaSpecie.add(p);
    } else if (nomi.any((n) => n.isNotEmpty && n.first == cercata.first)) {
      stessoGenere.add(p);
    }
  }
  return (stessaSpecie: stessaSpecie, stessoGenere: stessoGenere);
}

/// Riconosce una pianta da una foto con l'API di Pl@ntNet
/// (https://my.plantnet.org). La foto viene analizzata e non conservata.
class RiconoscitorePlantNet {
  RiconoscitorePlantNet({http.Client? client, this.chiave = chiavePlantNet})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String chiave;

  bool get attivo => chiave.isNotEmpty;

  Future<List<Ipotesi>> riconosci(Uint8List foto) async {
    final url = Uri.https('my-api.plantnet.org', '/v2/identify/all', {
      'api-key': chiave,
      'lang': 'it',
      'nb-results': '5',
    });
    final richiesta = http.MultipartRequest('POST', url)
      ..fields['organs'] = 'auto'
      ..files.add(
        http.MultipartFile.fromBytes('images', foto, filename: 'foto.jpg'),
      );
    // La chiave è autorizzata solo per il sito dell'app. Il browser aggiunge
    // da solo questa intestazione; l'app sul telefono la dichiara uguale.
    if (!kIsWeb) richiesta.headers['Origin'] = origineApp;

    final http.Response risposta;
    try {
      risposta = await http.Response.fromStream(
        await _client.send(richiesta).timeout(const Duration(seconds: 30)),
      );
    } catch (_) {
      throw const ErroreRiconoscimento(
        'Non riesco a contattare il servizio. Controlla la connessione.',
      );
    }
    switch (risposta.statusCode) {
      case 200:
        return leggiRisposta(
          jsonDecode(utf8.decode(risposta.bodyBytes)) as Map<String, dynamic>,
        );
      case 404:
        // Pl@ntNet risponde così quando nella foto non riconosce nessuna specie.
        return const [];
      case 429:
        throw const ErroreRiconoscimento(
          'Per oggi sono finiti i riconoscimenti gratuiti. Riprova domani.',
        );
      default:
        throw ErroreRiconoscimento(
          'Il servizio di riconoscimento non è disponibile '
          '(errore ${risposta.statusCode}). Riprova più tardi.',
        );
    }
  }
}
