import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:piantalapp/dati/donazioni.dart';
import 'package:piantalapp/schermate/sostieni.dart';

class _DonazioniFinte extends Donazioni {
  _DonazioniFinte(List<ProductDetails> offerte) {
    this.offerte = offerte;
    stato = offerte.isEmpty
        ? StatoDonazioni.nonDisponibili
        : StatoDonazioni.pronte;
  }

  final donate = <String>[];

  @override
  Future<void> avvia() async {}

  @override
  Future<void> dona(ProductDetails offerta) async {
    donate.add(offerta.id);
    grazie = true;
    notifyListeners();
  }
}

ProductDetails _offerta(String id, String prezzo, double valore) =>
    ProductDetails(
      id: id,
      title: 'Donazione',
      description: '',
      price: prezzo,
      rawPrice: valore,
      currencyCode: 'EUR',
    );

void main() {
  testWidgets('mostra le donazioni di Google Play e ringrazia', (tester) async {
    final donazioni = _DonazioniFinte([
      _offerta('donazione_1', '1,00 €', 1),
      _offerta('donazione_3', '3,00 €', 3),
    ]);
    await tester.pumpWidget(MaterialApp(home: Sostieni(donazioni: donazioni)));

    expect(find.text('Dona 1,00 €'), findsOneWidget);
    expect(find.text('Dona 3,00 €'), findsOneWidget);
    await tester.tap(find.text('Dona 3,00 €'));
    await tester.pump();
    expect(donazioni.donate, ['donazione_3']);
    expect(find.text('Grazie di cuore per il tuo sostegno!'), findsOneWidget);
  });

  testWidgets('senza Google Play spiega dove donare', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Sostieni(donazioni: _DonazioniFinte([]))),
    );
    expect(find.textContaining('Google Play Store'), findsOneWidget);
    expect(find.text('Altri modi per aiutare'), findsOneWidget);
  });
}
