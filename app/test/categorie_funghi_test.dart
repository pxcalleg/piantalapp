import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/main.dart';
import 'package:piantalapp/modello/etichette.dart';
import 'package:piantalapp/modello/pianta.dart';
import 'package:piantalapp/schermate/elenco_piante.dart';
import 'package:piantalapp/schermate/funghi.dart';

void main() {
  final pacchetto = File('assets/piante.json').readAsStringSync();
  final piante = leggiPacchetto(pacchetto)!;
  final funghi = leggiFunghi(pacchetto)!;
  final perId = {for (final p in piante) p.id: p};

  test('ogni pianta ha una categoria conosciuta', () {
    for (final p in piante) {
      expect(etichetteGruppo, contains(p.gruppo), reason: p.id);
    }
    expect(perId['pothos']!.gruppo, 'appartamento');
    expect(perId['aloe-vera']!.gruppo, 'grasse');
    expect(perId['phalaenopsis']!.gruppo, 'orchidee');
    expect(perId['rosa-inglese']!.gruppo, 'esterno');
  });

  test(
    'una scheda salvata senza categoria la ricava dalle caratteristiche',
    () {
      final dati = (jsonDecode(pacchetto)['piante'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['id'] == 'echeveria');
      final vecchia = Pianta.fromJson({...dati}..remove('gruppo'));
      expect(vecchia.gruppo, 'grasse');
    },
  );

  test('l\'elenco completo è diviso per categoria, nell\'ordine previsto', () {
    final voci = perCategoria(piante);
    final titoli = voci.whereType<String>().toList();
    expect(titoli, etichetteGruppo.keys.toList());
    expect(voci.whereType<Pianta>(), hasLength(piante.length));
    // Dopo ogni titolo vengono solo piante di quella categoria.
    String? attuale;
    for (final v in voci) {
      if (v is String) attuale = v;
      if (v is Pianta) expect(v.gruppo, attuale, reason: v.id);
    }
  });

  test('legge i funghi con nome comune e nome latino tra parentesi', () {
    expect(funghi, hasLength(greaterThanOrEqualTo(5)));
    final porcino = funghi.firstWhere((f) => f.id == 'porcino');
    expect(porcino.titolo, 'Porcino (Boletus edulis)');
    for (final f in funghi) {
      expect(etichetteCommestibilita, contains(f.commestibilita));
      // Chi raccoglie un commestibile deve sapere con cosa può confonderlo.
      if (f.commestibilita.startsWith('commestibile')) {
        expect(f.sosia, isNotEmpty, reason: f.id);
      }
    }
    expect(cercaFunghi(funghi, 'boletus').map((f) => f.id), ['porcino']);
    expect(cercaFunghi(funghi, 'gallinaccio').map((f) => f.id), ['finferlo']);
  });

  test('un pacchetto senza funghi dà un elenco vuoto', () {
    expect(leggiFunghi('{"schema_version": 1, "piante": []}'), isEmpty);
  });

  testWidgets('filtra per categoria e apre la sezione Funghi con l\'avviso', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final cartella = Directory.systemTemp.createTempSync('piantalapp');
    final archivio = ArchivioPiante(
      client: MockClient((_) async => http.Response('', 404)),
      cartella: () async => cartella,
    );
    await tester.pumpWidget(PiantalApp(archivio: archivio));
    await tester.runAsync(archivio.carica);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Orchidee'));
    await tester.pumpAndSettle();
    expect(find.text('Dendrobium'), findsOneWidget);
    expect(find.text('Pothos'), findsNothing);

    await tester.tap(find.text('Funghi'));
    await tester.pumpAndSettle();
    expect(find.text('Attenzione: rischio di avvelenamento'), findsOneWidget);
    expect(find.byTooltip('Riconosci una pianta da una foto'), findsNothing);
    final porcino = find.text('Porcino (Boletus edulis)', findRichText: true);
    expect(porcino, findsOneWidget);

    await tester.tap(porcino);
    await tester.pumpAndSettle();
    expect(find.text('Attenzione: rischio di avvelenamento'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Con cosa si può confondere'),
      200,
    );
    expect(
      find.text('Boleto satana (Rubroboletus satanas)', findRichText: true),
      findsOneWidget,
    );
  });
}
