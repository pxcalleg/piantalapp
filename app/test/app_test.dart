import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/main.dart';

void main() {
  testWidgets('mostra l\'elenco, filtra e apre una scheda', (tester) async {
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

    // L'elenco è lungo: scorriamo fino alle piante cercate.
    final elenco = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Pothos'),
      300,
      scrollable: elenco,
    );
    expect(find.text('Pothos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sansevieria'),
      300,
      scrollable: elenco,
    );
    expect(find.text('Sansevieria'), findsOneWidget);
    // Torniamo in cima, dove ci sono i filtri.
    await tester.fling(elenco, const Offset(0, 3000), 3000);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Terrarium'));
    await tester.pumpAndSettle();
    expect(find.text('Sansevieria'), findsNothing);
    expect(find.text('Fittonia'), findsOneWidget);

    await tester.tap(find.text('Fittonia'));
    await tester.pumpAndSettle();
    expect(find.text('Fittonia albivenis'), findsOneWidget);
    expect(find.textContaining('Scheda in bozza'), findsOneWidget);
    expect(find.textContaining('Foto: Mokkie'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Tossicità'), 300);
    expect(find.text('Tossicità'), findsOneWidget);
  });
}
