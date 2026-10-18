import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'grasse_comune.dart';

/// Echeveria elegans: rosetta compatta di foglie carnose a spatola,
/// azzurro-grigie e pruinose, con la punta rosata.
class Echeveria extends Specie {
  const Echeveria();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.65, alto: 2.0, basso: -1.45);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF8AA7A6),
    nuova: Color(0xFFA9C4BE),
    retro: Color(0xFFB4C8C4),
  );

  @override
  double get lucentezza => 0.15;

  @override
  double get quotaATerra => 0.6;

  @override
  bool get marciumeAMacchie => true;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final f = filata(s);
    rosetta(c, s, const V3(0, 0.08, 0), 1, f, 0);
    // Rigogliosa: getta piccole rosette figlie attorno.
    if (s.vigore > 0.85) {
      for (var i = 0; i < 3; i++) {
        final a = 0.8 + i * 2.1;
        rosetta(c, s, V3.cilindro(a, 0.72, -0.02), 0.38, 0, 200 + i * 40);
      }
    }
  }

  void rosetta(
    Costruttore c,
    StatoPianta s,
    V3 centro,
    double scala,
    double f,
    int semeBase,
  ) {
    final w = s.appassimento;
    final n = ((22 + 10 * s.vigore) * (1 - 0.35 * f) * (scala < 1 ? 0.6 : 1))
        .round();
    // Con poca luce il fusto si allunga e si piega verso la finestra.
    final altezzaFusto = 0.06 + 1.25 * f;
    final piega = versoLuce * (0.45 * f);
    V3 fusto(double t) =>
        centro + V3.su * (altezzaFusto * t) + piega * (t * t) * scala;
    if (f > 0.05) {
      c.fusto(
        [for (var i = 0; i <= 6; i++) fusto(i / 6)],
        spessore: 0.1,
        spessoreFinale: 0.08,
        colore: const Color(0xFF9AAE8C),
        marcisce: true,
      );
    }
    for (var k = 0; k < n; k++) {
      final seme = semeBase + k + 3;
      final rnd = math.Random(seme);
      final t = k / n; // 0 = foglie esterne e vecchie
      final eta = t;
      final angolo = k * 2.39996 + rnd.nextDouble() * 0.15;
      final radiale = V3.cilindro(angolo, 1, 0);
      final m = sintomiGrasse(c, s, seme, eta);
      final base =
          fusto(f > 0.05 ? 0.15 + 0.85 * t : 1) + radiale * (0.04 * scala);
      final lunghezza =
          scala *
          (0.98 - 0.62 * t) *
          (0.85 + 0.25 * s.vigore) *
          (1 - 0.3 * f) *
          (0.92 + 0.16 * rnd.nextDouble());
      // Esterne quasi distese, interne erette; filata o assetata si apre.
      var elev = 0.12 + 1.15 * t * t - 0.5 * w * (1 - t);
      elev = elev * (1 - 0.6 * f) - 0.15 * f;
      final dir = radiale * math.cos(elev) + V3.su * math.sin(elev);
      c.foglia(
        Foglia(
          base: base,
          controllo:
              base +
              dir * (lunghezza * 0.5) +
              V3.su * (-lunghezza * 0.04 * (1 - t)),
          punta: c.fuoriDalVaso(
            base +
                dir * lunghezza +
                V3.su * (lunghezza * (0.12 * (1 - t) - 0.25 * w)),
          ),
          larghezza: 0.3 * (1 - 0.35 * s.secchezza - 0.2 * f),
          forma: Forma.spatola,
          motivo: Motivo.echeveria,
          eta: eta,
          seme: seme,
          nuova: t > 0.8 && s.vigore > 0.5,
          coppa: 0.4 + 0.3 * s.secchezza,
          sintomi: m,
        ),
      );
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Rosetta compatta e simmetrica, foglie sode azzurro-grigie con un velo di pruina e la punta rosata.',
      fare: 'Tanta luce, anche sole diretto; acqua solo quando il terriccio è completamente asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Rosetta piena e larga, con piccole rosette figlie che spuntano attorno.',
      fare: 'Le figlie si staccano in primavera e si piantano in un vasetto con terriccio per piante grasse.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gonfie, traslucide e giallastre; le più basse si ammorbidiscono.',
      fare: 'Sospendi l\'acqua finché il terriccio è asciutto fino in fondo, e niente acqua nel sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie che si staccano al tocco, fusto nero e molle alla base.',
      fare: 'Taglia la rosetta sopra la parte nera, lasciala asciugare qualche giorno e ripiantala in terriccio asciutto.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie esterne raggrinzite e sottili che si seccano, rosetta che si apre.',
      fare: 'È normale che le foglie più basse secchino; se sono raggrinzite tutte, annaffia a fondo una volta.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Pianta filata: il fusto si allunga verso la finestra, foglie distanziate, piatte e pallide.',
      fare: 'Mettila al sole. Il fusto allungato non torna indietro: si può tagliare la rosetta e ripiantarla.',
    ),
    Scenario.troppoSole: (
      vedi: 'Macchie chiare o brune sulle foglie esposte dopo un passaggio brusco al sole estivo.',
      fare: 'Abituala al sole un po\' alla volta; nelle ore più calde d\'estate, un velo d\'ombra.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie traslucide e poi scure e molli, che si staccano dopo il gelo.',
      fare: 'Tienila sopra i 5 °C e all\'asciutto d\'inverno; togli le foglie danneggiate.',
    ),
  };
}
