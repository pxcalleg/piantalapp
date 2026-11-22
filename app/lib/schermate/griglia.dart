import 'package:flutter/material.dart';

/// Da questa larghezza in su (tablet, computer) le schede dell'elenco si
/// dispongono in una griglia di riquadri compatti invece che in righe larghe
/// quanto lo schermo.
const larghezzaGriglia = 700.0;

/// Griglia di schede alte quanto la loro foto (96 punti, di più se il testo
/// del telefono è ingrandito) e larghe al massimo 480 punti.
Widget grigliaSchede(
  BuildContext context, {
  required int quante,
  required Widget Function(BuildContext, int) scheda,
}) {
  final altezza = MediaQuery.textScalerOf(context).scale(96).clamp(96.0, 160.0);
  return SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
    sliver: SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 480,
        mainAxisExtent: altezza,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: quante,
      itemBuilder: scheda,
    ),
  );
}
