import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

/// Fittonia: cuscino basso di fusti morbidi con foglie opposte, ovali, a
/// rete di venature bianche. Quando ha sete "sviene" di colpo.
class Fittonia extends Specie {
  const Fittonia();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.1, alto: 1.75, basso: -1.95);

  @override
  Vaso get vaso =>
      const Vaso(altezza: 1.05, raggioFondo: 0.8, colore: Vaso.salvia);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2F6A35),
    nuova: Color(0xFF5E9A4A),
    retro: Color(0xFF8BA982),
  );

  @override
  double get lucentezza => 0.2;

  @override
  double get quotaATerra => 0.5;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    const fusti = 12;
    for (var i = 0; i < fusti; i++) {
      final rnd = math.Random(i + 31);
      final angolo = i * 2 * math.pi / fusti + rnd.nextDouble() * 0.4;
      final centrale = i % 4 == 0;
      final r0 = 0.04 + 0.22 * rnd.nextDouble();
      // Con poca luce i fusti si allungano.
      final lunghezza =
          (centrale ? 0.4 : 0.75 + 0.35 * rnd.nextDouble()) *
          (0.85 + 0.35 * (1 - v));
      final altezza =
          (centrale ? 0.7 : 0.4 + 0.2 * rnd.nextDouble()) * (1 - 0.85 * w);
      final cade = (0.15 + 0.2 * rnd.nextDouble()) + 1.1 * w;

      V3 punto(double t) => c.fuoriDalVaso(
        V3.cilindro(
          angolo,
          r0 + lunghezza * t,
          altezza * math.sin(math.pi * 0.5 * math.min(t * 1.4, 1)) -
              cade * t * t,
        ),
      );

      c.fusto(
        [for (var k = 0; k <= 9; k++) punto(k / 9)],
        spessore: 0.022,
        spessoreFinale: 0.014,
        colore: const Color(0xFF7D8C58),
        marcisce: true,
      );

      final coppie = (3 * (0.5 + 0.6 * v)).round().clamp(1, 4);
      for (var k = 0; k < coppie; k++) {
        final t = 0.25 + 0.75 * (k + 0.5) / coppie;
        final base = punto(t);
        final tangente = (punto(math.min(t + 0.04, 1)) - base).normalizzato();
        final lato = V3.su.cross(tangente).normalizzato();
        final nuova = k == coppie - 1 && v > 0.5;
        for (final verso in const [1.0, -1.0]) {
          final seme = i * 40 + k * 2 + (verso > 0 ? 0 : 1);
          final rf = math.Random(seme);
          final dir =
              (lato * (0.85 * verso) +
                      tangente * 0.4 +
                      V3.su * (0.4 - 1.5 * w + (rf.nextDouble() - 0.5) * 0.3))
                  .normalizzato();
          final lunghezzaFoglia =
              (0.42 + 0.12 * v) *
              (0.85 + 0.3 * rf.nextDouble()) *
              (nuova ? 0.65 : 1);
          final attacco = base + dir * 0.025;
          c.foglia(
            Foglia(
              picciolo: base,
              base: attacco,
              controllo:
                  attacco +
                  dir * (lunghezzaFoglia * 0.5) +
                  V3.su * (lunghezzaFoglia * 0.06),
              punta:
                  attacco +
                  dir * lunghezzaFoglia +
                  V3.su * (-lunghezzaFoglia * (0.1 + 0.5 * w)),
              larghezza: 0.36,
              forma: Forma.ovalePiccola,
              motivo: Motivo.fittonia,
              eta: t,
              seme: seme,
              nuova: nuova,
              coppa: 0.2,
            ),
          );
        }
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Cuscino compatto di foglie con le venature bianche ben disegnate.',
      fare: 'Luce media indiretta e terriccio sempre leggermente umido; ama l\'umidità alta.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Tante foglie nuove: la pianta si allarga e copre il vaso.',
      fare: 'Cima le punte per tenerla compatta; concima a un quarto della dose ogni mese, da aprile a settembre.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle e molli, terriccio fradicio.',
      fare: 'Annaffia poco e spesso, senza lasciare acqua nel sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Fusti neri e molli alla base, muffa bianca sul terriccio.',
      fare: 'Salva le punte sane come talee in acqua o in terriccio nuovo; butta le parti marce.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'La pianta "sviene": si affloscia di colpo e le foglie pendono oltre il bordo del vaso.',
      fare: 'Annaffia subito: si riprende in poche ore. Non farlo succedere spesso, si indebolisce.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Fusti lunghi e sottili, poche foglie, venature meno nette.',
      fare: 'Avvicinala a una finestra senza sole diretto e cima i fusti allungati.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie scolorite con chiazze bruciate e bordi secchi.',
      fare: 'Niente sole diretto, soprattutto dietro il vetro di un terrarium.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che si afflosciano e cadono, colori spenti.',
      fare: 'Tienila sopra i 18 °C e lontana dai vetri freddi d\'inverno.',
    ),
  };
}
