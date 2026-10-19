import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'grasse_comune.dart';

/// Rosetta di foglie carnose e affusolate che nascono dal terriccio, usata
/// dall'aloe (grande) e dall'haworthia (piccola e fitta).
void rosettaAffusolata(
  Costruttore c,
  StatoPianta s, {
  required V3 centro,
  required int foglie,
  required double lunghezza,
  required double larghezza,
  required double elevBase,
  required double elevCima,
  required Motivo motivo,
  required int semeBase,
  double incurva = 0.15,
}) {
  final f = filata(s);
  final w = s.appassimento;
  for (var k = 0; k < foglie; k++) {
    final seme = semeBase + k;
    final rnd = math.Random(seme);
    final t = k / foglie; // 0 = foglie esterne e vecchie
    final angolo = k * 2.39996 + rnd.nextDouble() * 0.2;
    final radiale = V3.cilindro(angolo, 1, 0);
    final m = sintomiGrasse(c, s, seme, t);
    // Foglia molle che si accascia: marciume, gelo o caduta.
    final piega =
        (m.marcia * (0.25 + 0.75 * s.marciume) +
                (m.cade ? 0.55 : 0) +
                0.2 * w * (1 - t))
            .clamp(0.0, 1.0);
    final base = centro + radiale * (0.03 + 0.08 * (1 - t)) + V3.su * -0.04;
    final l =
        lunghezza *
        (0.55 + 0.45 * math.sqrt(1 - t * 0.85)) *
        (0.8 + 0.3 * s.vigore) *
        (1 + 0.25 * f) *
        (0.9 + 0.2 * rnd.nextDouble());
    var elev = elevBase + (elevCima - elevBase) * t;
    // Filata: foglie lunghe, piatte e molli che si aprono e si piegano.
    elev = elev - 0.55 * f - 0.8 * piega;
    final dir = radiale * math.cos(elev) + V3.su * math.sin(elev);
    final lean = versoLuce * (0.25 * f * l);
    final cade = l * (incurva + 0.35 * f + 0.25 * piega);
    c.foglia(
      Foglia(
        base: base,
        controllo: base + dir * (l * 0.5) + V3.su * (l * 0.04),
        punta: c.fuoriDalVaso(base + dir * l + V3.su * -cade + lean),
        larghezza: larghezza * (1 - 0.3 * s.secchezza - 0.25 * f),
        forma: Forma.triangolo,
        motivo: motivo,
        eta: t,
        seme: seme,
        nuova: t > 0.82 && s.vigore > 0.5,
        coppa: 0.45 + 0.4 * s.secchezza,
        rollio: (rnd.nextDouble() - 0.5) * 0.3,
        sintomi: Sintomi(
          gialla: m.gialla,
          secca: m.secca * 0.8 + 0.25 * w * (1 - t),
          marcia: m.marcia,
          bruciata: m.bruciata,
          variegatura: m.variegatura,
        ),
      ),
    );
  }
}

/// Aloe vera: rosetta di foglie spesse, grigio-verdi, affusolate e con i
/// dentini sul bordo.
class AloeVera extends Specie {
  const AloeVera();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.2, alto: 2.9, basso: -1.6);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF6E9064),
    nuova: Color(0xFF86A877),
    retro: Color(0xFF8DA684),
  );

  @override
  double get lucentezza => 0.3;

  @override
  bool get foglieCadono => false;

  @override
  bool get marciumeAMacchie => true;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    rosettaAffusolata(
      c,
      s,
      centro: const V3(0, 0, 0),
      foglie: (11 + 6 * s.vigore).round(),
      lunghezza: 1.7,
      larghezza: 0.17,
      elevBase: 0.7,
      elevCima: 1.3,
      motivo: Motivo.aloe,
      semeBase: 11,
    );
    // Rigogliosa: polloni alla base.
    if (s.vigore > 0.85) {
      for (var i = 0; i < 2; i++) {
        rosettaAffusolata(
          c,
          s,
          centro: V3.cilindro(1.0 + i * 2.6, 0.7, 0),
          foglie: 6,
          lunghezza: 0.55,
          larghezza: 0.15,
          elevBase: 0.7,
          elevCima: 1.3,
          motivo: Motivo.aloe,
          semeBase: 300 + i * 20,
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie spesse, sode e grigio-verdi, rivolte verso l\'alto, con macchioline chiare e dentini sul bordo.',
      fare: 'Luce intensa, anche qualche ora di sole; acqua solo quando il terriccio è asciutto fino in fondo.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Rosetta piena con foglie nuove al centro e polloni che spuntano alla base.',
      fare: 'In primavera stacca i polloni con un po\' di radici e mettili in un vasetto: sono nuove piante.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gonfie e giallastre, molli e traslucide alla base, terriccio sempre bagnato.',
      fare: 'Smetti di annaffiare finché il terriccio è asciutto; usa terriccio per piante grasse e vaso in terracotta.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie che si afflosciano e si piegano, base scura e molle, cattivo odore.',
      fare: 'Togli la pianta dal vaso, taglia le parti marce, lascia asciugare qualche giorno e rinvasa in terriccio asciutto.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie sottili che si incurvano verso l\'interno, punte secche, terriccio staccato dal vaso.',
      fare: 'Annaffia a fondo una volta e lascia scolare: in pochi giorni le foglie tornano piene.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Foglie lunghe, sottili e pallide che si aprono e si piegano verso la finestra.',
      fare: 'Spostala nel punto più luminoso della casa; d\'estate sta bene fuori, al riparo dalla pioggia.',
    ),
    Scenario.troppoSole: (
      vedi:
          'Foglie che si tingono di rosso-bruno, con chiazze chiare e secche.',
      fare: 'È stress da sole: dalle un po\' d\'ombra nelle ore calde e torna verde in qualche settimana.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie molli che si piegano, con macchie traslucide e poi scure.',
      fare: 'Sotto i 10 °C va in casa; d\'inverno pochissima acqua. Taglia le foglie rovinate alla base.',
    ),
  };
}
