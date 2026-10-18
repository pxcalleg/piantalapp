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

    expect(find.text('Pothos'), findsOneWidget);
    // Le piante sono tante: la sansevieria può essere più in basso.
    await tester.dragUntilVisible(
      find.text('Sansevieria'),
      find.byType(CustomScrollView).first,
      const Offset(0, -300),
    );
    expect(find.text('Sansevieria'), findsOneWidget);
    await tester.dragUntilVisible(
      find.widgetWithText(FilterChip, 'Terrarium'),
      find.byType(CustomScrollView).first,
      const Offset(0, 300),
    );

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
