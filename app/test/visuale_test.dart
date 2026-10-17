import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/main.dart';
import 'package:piantalapp/visuale/pothos_3d.dart';
import 'package:piantalapp/visuale/stato_pianta.dart';

void main() {
  test('ogni scenario si disegna a ogni angolazione e con ogni luce', () async {
    for (final s in Scenario.values) {
      for (final rotazione in [0.0, 1.6, 3.2, 4.8]) {
        for (final luce in [0.0, 0.5, 1.0]) {
          final rec = ui.PictureRecorder();
          PothosPainter(
            stato: s.stato,
            rotazione: rotazione,
            luce: luce,
          ).paint(Canvas(rec), const Size(300, 300));
          rec.endRecording().dispose();
        }
      }
    }
  });

  test('gli scenari hanno valori tra 0 e 1', () {
    for (final s in Scenario.values) {
      final v = s.stato;
      for (final x in [
        v.vigore,
        v.ingiallimento,
        v.secchezza,
        v.marciume,
        v.spente,
        v.appassimento,
        v.caduta,
        v.bruciature,
        v.umiditaTerreno,
        s.luce,
      ]) {
        expect(x, inInclusiveRange(0, 1), reason: s.name);
      }
    }
  });

  test('il passaggio tra due stati è graduale', () {
    final m = StatoPianta.lerp(
      Scenario.sana.stato,
      Scenario.pocaAcqua.stato,
      0.5,
    );
    expect(m.appassimento, closeTo(0.425, 1e-9));
    expect(m.umiditaTerreno, closeTo(0.25, 1e-9));
  });

  testWidgets('dalla scheda del pothos si apre la pianta interattiva', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final archivio = ArchivioPiante(
      client: MockClient((_) async => http.Response('', 404)),
      cartella: () async => Directory.systemTemp.createTempSync('piantalapp'),
    );
    await tester.pumpWidget(PiantalApp(archivio: archivio));
    await tester.runAsync(archivio.carica);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pothos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ruota e simula'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('scena-pianta')), findsOneWidget);
    expect(find.textContaining('Cosa vedi: Foglie sode'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Poca acqua'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Cosa vedi: Foglie flosce'), findsOneWidget);

    final scena = tester.widget<CustomPaint>(
      find.byKey(const Key('scena-pianta')),
    );
    final pittore = scena.painter! as PothosPainter;
    expect(pittore.stato.umiditaTerreno, 0);
    expect(pittore.luce, Scenario.pocaAcqua.luce);

    // Trascinare ferma la rotazione automatica e ruota la pianta.
    final prima = pittore.rotazione;
    await tester.drag(
      find.byKey(const Key('scena-pianta')),
      const Offset(120, 0),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final dopo =
        (tester
                    .widget<CustomPaint>(find.byKey(const Key('scena-pianta')))
                    .painter!
                as PothosPainter)
            .rotazione;
    expect(dopo, isNot(closeTo(prima, 0.01)));
  });
}
