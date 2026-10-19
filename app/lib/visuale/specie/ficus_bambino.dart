import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

const _angoloAureo = 2.39996;

/// Ficus Bambino (Ficus lyrata 'Bambino'): versione nana del Ficus lyrata,
/// un cespuglio compatto di fusti corti e fitti di foglie a violino più
/// piccole, rigide e rivolte verso l'alto.
class FicusBambino extends Specie {
  const FicusBambino();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.0, alto: 3.4, basso: -2.1);

  @override
  Vaso get vaso => const Vaso(colore: Vaso.salvia, lucido: true);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2F6427),
    nuova: Color(0xFF7FB24A),
    retro: Color(0xFF86A465),
  );

  @override
  double get lucentezza => 0.75;

  @override
  bool get marciumeAMacchie => true;

  @override
  double get quotaATerra => 0.6;

  static const _fusti = [
    (x: 0.0, z: 0.0, altezza: 2.3, pendenza: V3(0.05, 0, 0.04), foglie: 13),
    (x: 0.2, z: 0.12, altezza: 1.75, pendenza: V3(0.35, 0, 0.2), foglie: 10),
    (x: -0.18, z: 0.1, altezza: 1.5, pendenza: V3(-0.35, 0, 0.15), foglie: 11),
    (x: 0.02, z: -0.2, altezza: 1.9, pendenza: V3(0.0, 0, -0.35), foglie: 11),
  ];

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    for (var i = 0; i < _fusti.length; i++) {
      final f = _fusti[i];
      final base = V3(f.x, -0.06, f.z);
      // Con poca luce i fusti si allungano e si piegano verso la finestra.
      final altezza = f.altezza * (0.9 + 0.25 * (1 - v));
      final pendenza = f.pendenza * (1 + 0.6 * w) + V3(-0.3 * (1 - v), 0, 0);
      V3 fusto(double t) =>
          base + V3.su * (altezza * t) + pendenza * (t * t * altezza * 0.5);
      c.fusto(
        [for (var k = 0; k <= 8; k++) fusto(k / 8)],
        spessore: 0.07,
        spessoreFinale: 0.035,
        colore: const Color(0xFF7E7460),
      );

      // Foglie fitte fin quasi al terriccio; con poca luce cadono le basse.
      final inizio = 0.12 + 0.4 * (1 - v);
      final n = (f.foglie * (0.45 + 0.55 * v)).round();
      for (var k = 0; k < n; k++) {
        final seme = i * 40 + k + 501;
        final rf = math.Random(seme);
        final t = inizio + (0.98 - inizio) * k / math.max(1, n - 1);
        final punto = fusto(t);
        final radiale = V3.cilindro(i * 1.7 + k * _angoloAureo, 1, 0);
        final nuova = k >= n - 2 && v > 0.5;
        final lunghezza =
            (0.55 + 0.25 * v) *
            (0.85 + 0.25 * rf.nextDouble()) *
            (nuova ? 0.65 : 1) *
            (1 - 0.15 * s.secchezza);
        // Foglie rigide, tenute in su; con la sete si abbassano.
        final su = 0.45 + 0.6 * t - 1.5 * w + (nuova ? 0.8 : 0);
        final dir = (radiale + V3.su * su).normalizzato();
        final attacco = punto + dir * 0.05;
        c.foglia(
          Foglia(
            picciolo: punto,
            base: attacco,
            controllo:
                attacco + dir * (lunghezza * 0.5) + V3.su * (lunghezza * 0.06),
            punta:
                attacco +
                dir * lunghezza +
                V3.su * (-lunghezza * (0.1 + 0.4 * w)),
            larghezza: 0.42,
            forma: Forma.violino,
            motivo: Motivo.lyrata,
            eta: t,
            seme: seme,
            nuova: nuova,
            rollio: (rf.nextDouble() - 0.5) * 1.2,
            coppa: 0.32,
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Cespuglio compatto e fitto di foglie a violino verde scuro, lucide e rigide, rivolte verso l\'alto.',
      fare: 'Vicino a una finestra luminosa, anche con un po\' di sole del mattino; acqua quando i primi 3 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Foglie nuove verde chiaro in cima a ogni fusto e cespuglio pieno fino al vaso.',
      fare: 'Concima ogni 2-4 settimane da marzo a settembre a metà dose e ruota il vaso ogni mese perché cresca uniforme.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Macchie marroni scure sulle foglie e foglie basse che ingialliscono.',
      fare: 'Aspetta che i primi 3 cm di terriccio siano asciutti e non lasciare acqua nel sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Macchie scure che si allargano, foglie che cadono dal basso, terriccio fradicio.',
      fare: 'Sfila la zolla, taglia le radici marce e rinvasa in terriccio drenante con corteccia e perlite.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie che si abbassano e si accartocciano, con i bordi marroni e secchi.',
      fare: 'Annaffia a fondo e lascia sgocciolare; poi controlla il terriccio ogni settimana.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Fusti più lunghi e piegati verso la finestra, spogli in basso, foglie più piccole.',
      fare: 'Avvicinalo a una finestra luminosa e ruotalo spesso; in primavera puoi cimare i fusti per farlo infittire.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare e secche sulle foglie rivolte verso il vetro.',
      fare: 'Va bene il sole del mattino; d\'estate riparalo dal sole delle ore calde e abitualo al sole poco alla volta.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono all\'improvviso dopo una corrente fredda o uno spostamento.',
      fare: 'Tienilo sopra i 15 °C, lontano da porte, finestre aperte e termosifoni, e non spostarlo più.',
    ),
  };
}
