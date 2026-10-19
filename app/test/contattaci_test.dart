import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piantalapp/schermate/contattaci.dart';

void main() {
  test('il messaggio porta motivo, pianta e nome', () {
    final m = componiMessaggio(
      motivo: Motivo.nuovaPianta,
      messaggio: 'Mi piacerebbe la scheda del limone.',
      nome: 'Anna',
      pianta: ' Limone ',
    );
    expect(m.oggetto, 'Nuova pianta: Limone');
    expect(m.testo, contains('Pianta: Limone'));
    expect(m.testo, contains('Nome: Anna'));

    final mail = linkInvio(m);
    expect(mail.scheme, 'mailto');
    expect(mail.path, indirizzoContatti);
    expect(Uri.decodeComponent(mail.query), contains('Nuova pianta: Limone'));

    final github = linkInvio(m, github: true);
    expect(github.path, '/pxcalleg/piantalapp/issues/new');
    expect(github.queryParameters['title'], 'Nuova pianta: Limone');
  });

  testWidgets('il modulo chiede il messaggio e la pianta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Contattaci()));
    await tester.tap(find.text('Potete inserire una nuova pianta?'));
    await tester.pump();
    expect(find.text('Quale pianta?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Invia con la posta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Invia con la posta'));
    await tester.pump();
    expect(
      find.text('Scrivi un messaggio', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Scrivi il nome della pianta', skipOffstage: false),
      findsOneWidget,
    );
  });
}
