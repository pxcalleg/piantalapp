import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Le donazioni sono prodotti in-app «a consumo» creati nella Play Console con
// questi ID, così la stessa persona può donare più di una volta.
const idDonazioni = {'donazione_1', 'donazione_3', 'donazione_5'};

// Se Google Play non risponde, le donazioni risultano non disponibili.
const _attesa = Duration(seconds: 10);

enum StatoDonazioni { caricamento, pronte, nonDisponibili }

/// Le donazioni tramite Google Play: i pagamenti arrivano sul profilo
/// pagamenti collegato all'account della Play Console.
class Donazioni extends ChangeNotifier {
  Donazioni({this._negozio});

  InAppPurchase? _negozio;
  StreamSubscription<List<PurchaseDetails>>? _acquisti;

  StatoDonazioni stato = StatoDonazioni.caricamento;
  List<ProductDetails> offerte = [];

  /// Vero subito dopo una donazione andata a buon fine, per dire grazie.
  bool grazie = false;
  String? errore;

  /// Google Play esiste solo nell'app Android, non nella versione web.
  static bool get supportate =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Va chiamata all'avvio dell'app: Google Play può confermare un pagamento
  /// anche più tardi, e la conferma va registrata altrimenti viene rimborsato.
  Future<void> avvia() async {
    if (_acquisti != null) return;
    if (!supportate) {
      _imposta(StatoDonazioni.nonDisponibili);
      return;
    }
    try {
      final negozio = _negozio ??= InAppPurchase.instance;
      _acquisti = negozio.purchaseStream.listen(
        _aggiorna,
        onError: (_) => errore = 'Il pagamento non è andato a buon fine.',
      );
      if (!await negozio.isAvailable().timeout(_attesa)) {
        _imposta(StatoDonazioni.nonDisponibili);
        return;
      }
      final risposta = await negozio
          .queryProductDetails(idDonazioni)
          .timeout(_attesa);
      offerte = risposta.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      _imposta(
        offerte.isEmpty ? StatoDonazioni.nonDisponibili : StatoDonazioni.pronte,
      );
    } catch (_) {
      _imposta(StatoDonazioni.nonDisponibili);
    }
  }

  Future<void> dona(ProductDetails offerta) async {
    errore = null;
    grazie = false;
    notifyListeners();
    try {
      await _negozio!.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: offerta),
      );
    } catch (_) {
      errore = 'Non è stato possibile aprire il pagamento.';
      notifyListeners();
    }
  }

  Future<void> _aggiorna(List<PurchaseDetails> acquisti) async {
    for (final acquisto in acquisti) {
      switch (acquisto.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          grazie = true;
        case PurchaseStatus.error:
          errore = 'Il pagamento non è andato a buon fine.';
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }
      if (acquisto.pendingCompletePurchase) {
        await _negozio!.completePurchase(acquisto);
      }
    }
    notifyListeners();
  }

  void _imposta(StatoDonazioni nuovo) {
    stato = nuovo;
    notifyListeners();
  }

  @override
  void dispose() {
    _acquisti?.cancel();
    super.dispose();
  }
}

/// Le donazioni dell'app, avviate in main().
final donazioniApp = Donazioni();
