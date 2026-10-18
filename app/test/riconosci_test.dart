import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/modello/riconoscimento.dart';
import 'package:piantalapp/schermate/riconosci.dart';
import 'package:piantalapp/schermate/scheda_pianta.dart';

final _risposta = {
  'results': [
    {
      'score': 0.83,
      'species': {
        'scientificNameWithoutAuthor': 'Epipremnum aureum',
        'commonNames': ['Pothos'],
        'family': {'scientificNameWithoutAuthor': 'Araceae'},
      },
    },
    {
      'score': 0.06,
      'species': {
        'scientificNameWithoutAuthor': 'Rosa chinensis',
        'commonNames': [],
      },
    },
    {
      'score': 0.02,
      'species': {
        'scientificNameWithoutAuthor': 'Monstera deliciosa',
        'commonNames': ['Monstera'],
      },
    },
  ],
};

// Un'immagine PNG di 1x1 pixel, per l'anteprima della foto.
const _pngMinuscolo =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

void main() {
  final piante = leggiPacchetto(File('assets/piante.json').readAsStringSync())!;
  final ipotesi = leggiRisposta(_risposta);

  test('legge la risposta di Pl@ntNet', () {
    expect(ipotesi.map((i) => i.nomeScientifico), [
      'Epipremnum aureum',
      'Rosa chinensis',
      'Monstera deliciosa',
    ]);
    expect(ipotesi.first.percentuale, 83);
    expect(ipotesi.first.famiglia, 'Araceae');
  });

  test('collega le specie riconosciute alle schede', () {
    List<String> ids(List l) => [for (final p in l) p.id as String];

    final pothos = schedeCollegate(piante, ipotesi[0]);
    expect(ids(pothos.stessaSpecie), ['pothos']);

    final rosa = schedeCollegate(piante, ipotesi[1]);
    expect(rosa.stessaSpecie, isEmpty);
    expect(ids(rosa.stessoGenere), hasLength(5));

    final sinonimo = schedeCollegate(
      piante,
      const Ipotesi(nomeScientifico: 'Sansevieria trifasciata', punteggio: 1),
    );
    expect(ids(sinonimo.stessaSpecie), ['sansevieria']);

    final monstera = schedeCollegate(piante, ipotesi[2]);
    expect(monstera.stessaSpecie, isEmpty);
    expect(monstera.stessoGenere, isEmpty);
  });

  test('invia la foto con la chiave e il sito autorizzato', () async {
    late http.BaseRequest inviata;
    final client = MockClient.streaming((richiesta, _) async {
      inviata = richiesta;
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(_risposta))),
        200,
      );
    });
    final r = RiconoscitorePlantNet(client: client, chiave: 'prova');
    final risultato = await r.riconosci(Uint8List.fromList([1, 2, 3]));
    expect(risultato, hasLength(3));
    expect(inviata.url.host, 'my-api.plantnet.org');
    expect(inviata.url.queryParameters['api-key'], 'prova');
    expect(inviata.url.queryParameters['lang'], 'it');
    expect(inviata.headers['Origin'], origineApp);
  });

  test('spiega quando i riconoscimenti del giorno sono finiti', () async {
    final r = RiconoscitorePlantNet(
      client: MockClient((_) async => http.Response('', 429)),
      chiave: 'prova',
    );
    expect(
      r.riconosci(Uint8List(1)),
      throwsA(
        isA<ErroreRiconoscimento>().having(
          (e) => e.messaggio,
          'messaggio',
          contains('Riprova domani'),
        ),
      ),
    );
  });

  testWidgets('senza chiave avvisa che non è ancora attivo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Riconosci(
          piante: piante,
          riconoscitore: RiconoscitorePlantNet(chiave: ''),
        ),
      ),
    );
    expect(find.textContaining('non è ancora attivo'), findsOneWidget);
    expect(find.text('Scatta una foto'), findsNothing);
  });

  testWidgets('dalla foto mostra le specie e apre la scheda', (tester) async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode(_risposta), 200),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Riconosci(
          piante: piante,
          riconoscitore: RiconoscitorePlantNet(client: client, chiave: 'x'),
          sceltaFoto: (_) async => base64Decode(_pngMinuscolo),
        ),
      ),
    );
    await tester.tap(find.text('Dalla galleria'));
    await tester.pumpAndSettle();

    expect(find.text('Potrebbe essere'), findsOneWidget);
    expect(find.text('83%'), findsOneWidget);
    final assente = find.text('Non ancora presente nelle nostre schede');
    await tester.scrollUntilVisible(assente, 200);
    expect(assente, findsOneWidget);
    final pothos = find.text('Apri la scheda: Pothos');
    await tester.ensureVisible(pothos);
    await tester.pumpAndSettle();
    await tester.tap(pothos);
    await tester.pumpAndSettle();
    final scheda = tester.widget<SchedaPianta>(find.byType(SchedaPianta));
    expect(scheda.pianta.id, 'pothos');
  });
}
