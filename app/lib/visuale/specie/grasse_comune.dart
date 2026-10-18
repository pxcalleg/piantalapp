import '../motore_3d.dart';
import '../stato_pianta.dart';

/// Aiuti comuni alle piante grasse.

/// Vaso basso e piccolo in terracotta, adatto alle succulente.
const vasoGrasse = Vaso(altezza: 1.05, raggioFondo: 0.7);

/// Quanto la pianta è filata per poca luce: fusti allungati, foglie
/// distanziate e pallide, rosetta che si apre.
double filata(StatoPianta s) => ((0.45 - s.vigore) / 0.3).clamp(0.0, 1.0);

/// Danno da freddo: tessuti traslucidi e poi scuri e molli.
double gelo(StatoPianta s) =>
    ((s.caduta - 0.3) / 0.15).clamp(0.0, 1.0) *
    (1 - s.marciume).clamp(0.0, 1.0);

/// Direzione verso la finestra, verso cui si piegano le piante filate.
const versoLuce = V3(-0.85, 0, 0.5);

/// Sintomi tipici delle succulente a partire da quelli del motore: la
/// foglia filata è pallida, quella gelata ha macchie molli.
Sintomi sintomiGrasse(Costruttore c, StatoPianta s, int seme, double eta) {
  final m = c.sintomi(seme, eta);
  final g = gelo(s);
  return Sintomi(
    gialla: (m.gialla * 0.8 + 0.3 * filata(s)).clamp(0.0, 1.0),
    secca: m.secca,
    marcia: (m.marcia + g * 0.55 * (1 - eta)).clamp(0.0, 1.0),
    bruciata: m.bruciata,
    cade: m.cade,
    variegatura: m.variegatura,
  );
}
