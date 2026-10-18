import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/main.dart';
import 'package:piantalapp/visuale/modelli.dart';
import 'package:piantalapp/visuale/motore_3d.dart';
import 'package:piantalapp/visuale/stato_pianta.dart';

void main() {
  test('ogni pianta si disegna in ogni scenario, angolazione e luce', () {
    for (final specie in modelliVisuali.values) {
      for (final s in Scenario.values) {
        for (final rotazione in [0.0, 1.6, 3.2, 4.8]) {
          for (final luce in [0.0, 0.5, 1.0]) {
            final rec = ui.PictureRecorder();
            PiantaPainter(
              specie: specie,
              stato: s.stato,
              rotazione: rotazione,
              luce: luce,
            ).paint(Canvas(rec), const Size(300, 300));
            rec.endRecording().dispose();
          }
        }
      }
    }
  });

  test('ogni pianta spiega cosa si vede e cosa fare in ogni scenario', () {
    for (final MapEntry(key: id, value: specie) in modelliVisuali.entries) {
      for (final s in Scenario.values) {
        final testo = specie.testi[s];
        expect(testo, isNotNull, reason: '$id: ${s.name}');
        expect(testo!.vedi.trim(), isNotEmpty);
        expect(testo.fare.trim(), isNotEmpty);
      }
    }
  });

  test('ogni modello corrisponde a una scheda esistente', () {
    final ids = Directory('../dati/piante')
        .listSync()
        .map((f) => f.uri.pathSegments.last.replaceAll('.yaml', ''))
        .toSet();
    expect(ids, containsAll(modelliVisuali.keys));
    // Per ora ogni scheda ha la sua pianta interattiva.
    expect(modelliVisuali.keys.toSet(), ids);
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

    await tester.dragUntilVisible(
      find.text('Pothos'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.ensureVisible(find.text('Pothos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pothos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ruota e simula'));
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
    final pittore = scena.painter! as PiantaPainter;
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
                as PiantaPainter)
            .rotazione;
    expect(dopo, isNot(closeTo(prima, 0.01)));
  });

  testWidgets('anche la sansevieria ha la sua pianta interattiva', (
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

    final voce = find.text('Sansevieria');
    await tester.dragUntilVisible(
      voce,
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(voce.first);
    await tester.pumpAndSettle();

    // In testa alla scheda si passa dalla foto alla pianta 3D.
    expect(find.byType(Image), findsWidgets);
    await tester.tap(find.text('3D'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is PiantaPainter,
      ),
      findsOneWidget,
    );
    // La pianta 3D gira di continuo: torniamo alla foto per proseguire.
    await tester.tap(find.text('Foto'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Ruota e simula'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ruota e simula'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Cosa vedi: Foglie erette'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Marciume radicale'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('si piegano di lato'), findsOneWidget);
  });
}
