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

    // L'elenco è lungo: scorre fino alle piante cercate e poi torna su.
    final elenco = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Pothos'),
      300,
      scrollable: elenco,
    );
    expect(find.text('Pothos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sansevieria'),
      100,
      scrollable: elenco,
    );
    expect(find.text('Sansevieria'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Terrari'),
      -300,
      scrollable: elenco,
    );

    // Il filtro «Terrarium» non c'è più: per i terrari basta la categoria.
    expect(find.widgetWithText(FilterChip, 'Terrarium'), findsNothing);
    await tester.drag(elenco, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Terrari'));
    await tester.pumpAndSettle();
    expect(find.text('Sansevieria'), findsNothing);
    expect(find.text('Pothos'), findsNothing);
    expect(find.text('Azzera filtri'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Fittonia'),
      300,
      scrollable: elenco,
    );
    expect(find.text('Fittonia'), findsOneWidget);

    await tester.tap(find.text('Fittonia'));
    await tester.pumpAndSettle();
    expect(find.text('Fittonia albivenis'), findsOneWidget);
    expect(find.textContaining('Scheda in bozza'), findsOneWidget);
    expect(find.textContaining('Foto: Mokkie'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Tossicità'), 300);
    expect(find.text('Tossicità'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Come si propaga'), 300);
    expect(find.text('Come si propaga'), findsOneWidget);
    expect(find.textContaining('Quando:'), findsWidgets);
  });

  testWidgets('apre la pagina per sostenere lo sviluppo', (tester) async {
    final cartella = Directory.systemTemp.createTempSync('piantalapp');
    final archivio = ArchivioPiante(
      client: MockClient((_) async => http.Response('', 404)),
      cartella: () async => cartella,
    );
    await tester.pumpWidget(PiantalApp(archivio: archivio));
    await tester.runAsync(archivio.carica);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Sostieni lo sviluppo di PiantalAPP'));
    await tester.pumpAndSettle();
    expect(find.text('Sostieni lo sviluppo di PiantalAPP'), findsOneWidget);
    expect(find.text('Altri modi per aiutare'), findsOneWidget);
  });

  testWidgets('«Azzera filtri» toglie categoria, filtri e ricerca', (
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

    final tutte = archivio.piante.length;
    expect(find.text('$tutte piante'), findsOneWidget);
    expect(find.text('Azzera filtri'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Terrari'));
    await tester.tap(find.widgetWithText(FilterChip, 'Facile'));
    await tester.enterText(find.byType(SearchBar), 'pep');
    await tester.pumpAndSettle();
    expect(find.text('1 pianta'), findsOneWidget);

    await tester.tap(find.text('Azzera filtri'));
    await tester.pumpAndSettle();
    expect(find.text('$tutte piante'), findsOneWidget);
    expect(find.text('Azzera filtri'), findsNothing);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tutte'))
          .selected,
      isTrue,
    );
  });
}
