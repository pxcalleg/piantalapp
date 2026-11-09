import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/main.dart';
import 'package:piantalapp/modello/pianta.dart';

void main() {
  test('le schede spiegano marciume, cocciniglia e afidi con il rimedio', () {
    final dati =
        jsonDecode(File('assets/piante.json').readAsStringSync())
            as Map<String, dynamic>;
    final problemi = [
      for (final p in dati['piante'] as List)
        ...Pianta.fromJson(p as Map<String, dynamic>).problemiComuni,
    ];
    for (final parola in ['marciume', 'cocciniglia', 'afidi']) {
      final trovati = problemi.where(
        (pr) => pr.causa.toLowerCase().contains(parola),
      );
      expect(trovati, isNotEmpty, reason: parola);
      for (final pr in trovati) {
        expect(pr.sintomo.trim(), isNotEmpty);
        expect(pr.rimedio.trim(), isNotEmpty);
      }
    }
  });

  testWidgets('la scheda mostra i problemi comuni e non il simulatore', (
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

    await tester.enterText(find.byType(TextField), 'pothos');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pothos'));
    await tester.pumpAndSettle();

    expect(find.text('Ruota e simula'), findsNothing);
    expect(find.text('3D'), findsNothing);

    await tester.scrollUntilVisible(find.text('Problemi comuni'), 300);
    await tester.scrollUntilVisible(
      find.textContaining('Marciume radicale da troppa acqua'),
      200,
    );
    expect(
      find.textContaining('Marciume radicale da troppa acqua'),
      findsOneWidget,
    );
  });
}
