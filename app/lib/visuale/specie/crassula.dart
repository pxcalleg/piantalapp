import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'grasse_comune.dart';

/// Crassula ovata, albero di giada: tronchetto legnoso e ramificato con
/// foglie carnose ovali a coppie, verde giada e bordate di rosso.
class Crassula extends Specie {
  const Crassula();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.0, alto: 3.0, basso: -1.6);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3F7238),
    nuova: Color(0xFF6E9C4E),
    retro: Color(0xFF7FA06A),
  );

  @override
  double get lucentezza => 0.7;

  @override
  double get quotaATerra => 0.5;

  @override
  bool get marciumeAMacchie => true;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final f = filata(s);
    final w = s.appassimento;
    final v = s.vigore;
    // Con poca luce fusti più lunghi e sottili, piegati verso la finestra.
    final allunga = 1 + 0.45 * f;
    V3 tronco(double t) =>
        V3(0.06 * math.sin(t * 4), -0.05 + 1.0 * allunga * t, 0.04 * t) +
        versoLuce * (0.25 * f * t * t);
    c.fusto(
      [for (var i = 0; i <= 8; i++) tronco(i / 8)],
      spessore: 0.2 * (1 - 0.35 * f),
      spessoreFinale: 0.12 * (1 - 0.35 * f),
      colore: const Color(0xFF8B7B5E),
      marcisce: true,
    );

    final rami = (5 + 3 * v).round();
    for (var r = 0; r < rami; r++) {
      final rnd = math.Random(r + 21);
      final q = r / rami;
      final angolo = r * 2.39996 + rnd.nextDouble() * 0.3;
      final radiale = V3.cilindro(angolo, 1, 0);
      final attacco = tronco(0.55 + 0.45 * q);
      final lunghezza = (0.75 + 0.35 * rnd.nextDouble()) * (1.1 - 0.4 * q);
      final sale = 0.55 + 0.4 * rnd.nextDouble();
      final abbassa = 0.35 * w + 0.25 * f;
      V3 ramo(double t) =>
          attacco +
          radiale * (lunghezza * allunga * 0.8 * t) +
          V3.su * (lunghezza * allunga * (sale * t - abbassa * t * t)) +
          versoLuce * (0.3 * f * t);
      c.fusto(
        [for (var i = 0; i <= 5; i++) ramo(i / 5)],
        spessore: 0.1 * (1 - 0.35 * f),
        spessoreFinale: 0.05,
        colore: r.isEven ? const Color(0xFF8E8460) : const Color(0xFF7B8A55),
        marcisce: true,
      );

      // Coppie di foglie opposte e incrociate, fitte verso la punta.
      final coppie = (3 + 2 * v - 1.5 * f).round().clamp(1, 5);
      for (var p = 0; p < coppie; p++) {
        final t = 1 - p * (f > 0.5 ? 0.2 : 0.11);
        final nodo = ramo(t);
        final tangente = (ramo(math.min(t + 0.02, 1)) - ramo(t - 0.02))
            .normalizzato();
        var lato = V3.su.cross(tangente);
        if (lato.lunghezza < 0.2) lato = radiale.cross(tangente);
        lato = lato.normalizzato();
        final sopra = tangente.cross(lato).normalizzato();
        final asse = p.isEven ? lato : sopra;
        for (final verso in const [1.0, -1.0]) {
          final seme = r * 40 + p * 2 + (verso > 0 ? 0 : 1);
          final eta = 1 - p / 5;
          final m = sintomiGrasse(c, s, seme, eta * 0.8);
          final rf = math.Random(seme);
          final l =
              (0.36 + 0.06 * v) *
              (1 - 0.35 * f) *
              (0.85 + 0.3 * rf.nextDouble()) *
              (p == 0 && v > 0.6 ? 0.7 : 1);
          final dir =
              (asse * verso * 0.85 + tangente * 0.5 + V3.su * (0.1 - 0.5 * w))
                  .normalizzato();
          c.foglia(
            Foglia(
              base: nodo,
              controllo: nodo + dir * (l * 0.5),
              punta: nodo + dir * l + V3.su * (-l * 0.3 * w),
              larghezza: 0.46 * (1 - 0.3 * s.secchezza),
              forma: Forma.ovale,
              motivo: Motivo.crassula,
              eta: eta,
              seme: seme,
              nuova: p == 0 && v > 0.5,
              coppa: 0.15 + 0.3 * s.secchezza,
              rollio: (rf.nextDouble() - 0.5) * 0.4,
              sintomi: m,
            ),
          );
        }
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Tronchetto legnoso, rami robusti e foglie ovali carnose, lucide, verde giada con il bordo rossastro.',
      fare: 'Luce intensa e qualche ora di sole; acqua quando il terriccio è asciutto, d\'inverno quasi niente.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Chioma fitta di rami ben ramificati e foglie nuove verde chiaro in punta.',
      fare: 'Concima per piante grasse ogni mese da aprile a settembre; una spuntatina la rende più compatta.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle, molli e traslucide che cadono, terriccio sempre umido.',
      fare: 'Fai asciugare del tutto il terriccio prima di annaffiare e svuota sempre il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie che cadono in massa, base del tronco nera e molle.',
      fare: 'Salva le punte sane come talee: lasciale asciugare qualche giorno e piantale in terriccio per grasse.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie raggrinzite, più sottili e mosce; le più vecchie seccano.',
      fare: 'Annaffia a fondo una volta: in pochi giorni le foglie tornano sode e lisce.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Rami lunghi, sottili e piegati verso la finestra, poche foglie piccole e distanziate, niente rosso sul bordo.',
      fare: 'Mettila al sole: i rami nuovi saranno compatti. Accorcia quelli filati in primavera.',
    ),
    Scenario.troppoSole: (
      vedi: 'Bordo rosso molto acceso e chiazze chiare e secche sulle foglie più esposte.',
      fare: 'Un po\' di rosso è normale al sole; se compaiono chiazze, abituala gradualmente al sole estivo.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono, con macchie traslucide e poi scure.',
      fare: 'Tienila sopra i 7-10 °C, lontana da finestre aperte d\'inverno, e quasi asciutta.',
    ),
  };
}
