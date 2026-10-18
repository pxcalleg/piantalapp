import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piantalapp/schermate/info.dart';
import 'package:piantalapp/schermate/testata.dart';

void main() {
  testWidgets('la testata riporta alla prima pagina', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Testata()),
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const Info())),
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    expect(find.text('Informazioni'), findsOneWidget);

    await tester.tap(find.text('Informazioni'));
    await tester.pumpAndSettle();
    expect(find.text('Apri'), findsOneWidget);
    expect(find.text('Informazioni'), findsNothing);
  });
}
