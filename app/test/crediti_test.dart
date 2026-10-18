import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piantalapp/schermate/info.dart';

void main() {
  test('ogni foto ha autore, licenza libera e link', () {
    final crediti = jsonDecode(
      File('assets/immagini/crediti.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final lista in crediti.values) {
      for (final c in (lista as List).cast<Map<String, dynamic>>()) {
        expect(c['autore'], isNot(contains('machine-readable')));
        // Le stesse licenze accettate da scripts/immagini.py.
        expect(
          c['licenza'],
          matches(
            RegExp(
              r'^(CC0|CC BY(-SA)? \d(\.\d)?|Public domain)$',
              caseSensitive: false,
            ),
          ),
        );
        // Il pubblico dominio non ha un testo di licenza da linkare.
        if (c['licenza'] != 'Public domain') {
          expect(c['url_licenza'], startsWith('http'));
        }
        expect(c['pagina'], startsWith('https://commons.wikimedia.org/'));
        expect(File('assets/immagini/${c['file']}').existsSync(), isTrue);
      }
    }
  });

  testWidgets('la pagina dei crediti elenca le foto', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Info()));
    await tester.scrollUntilVisible(find.text('Crediti delle foto'), 200);
    await tester.tap(find.text('Crediti delle foto'));
    await tester.pumpAndSettle();
    expect(find.text('Aloe vera'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Dracaena trifasciata'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(find.textContaining('di Morrisjm'), 200);
    expect(find.textContaining('di Morrisjm'), findsOneWidget);
  });
}
