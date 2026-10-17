import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

const _angoloAureo = 2.39996;

/// Ficus benjamina: alberello con tronco, rami arcuati e ricadenti e tante
/// foglioline lucide con la punta allungata.
class FicusBenjamina extends Specie {
  const FicusBenjamina();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.0, alto: 3.05, basso: -2.15);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3B7A2E),
    nuova: Color(0xFF8CC456),
    retro: Color(0xFF93B373),
  );

  @override
  double get lucentezza => 0.75;

  @override
  double get quotaATerra => 0.35;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    const altezzaTronco = 2.5;
    V3 tronco(double t) => V3(
      0.07 * math.sin(t * 5),
      -0.05 + altezzaTronco * t,
      0.05 * math.cos(t * 6),
    );
    c.fusto(
      [for (var i = 0; i <= 12; i++) tronco(i / 12)],
      spessore: 0.12,
      spessoreFinale: 0.04,
      colore: const Color(0xFF8C7F6E),
    );

    const rami = 14;
    final rnd = math.Random(11);
    for (var r = 0; r < rami; r++) {
      final q = r / (rami - 1);
      final angolo = r * _angoloAureo + rnd.nextDouble() * 0.3;
      final attacco = tronco(0.36 + 0.62 * q);
      final radiale = V3.cilindro(angolo, 1, 0);
      final lunghezza =
          (1.55 - 0.75 * q) *
          (0.85 + 0.3 * rnd.nextDouble()) *
          (0.85 + 0.15 * v);
      final sale = (0.55 + 0.35 * rnd.nextDouble()) * (1 - 0.4 * w);
      final ricade = (0.45 + 0.35 * rnd.nextDouble()) * (1 + 1.2 * w);
      V3 ramo(double t) =>
          attacco +
          radiale * (lunghezza * t) +
          V3.su * (sale * t - (sale * 0.5 + ricade) * t * t);

      c.fusto(
        [for (var i = 0; i <= 8; i++) ramo(i / 8)],
        spessore: 0.04,
        spessoreFinale: 0.012,
        colore: const Color(0xFF7E7262),
      );

      final foglie = (16 * (0.4 + 0.75 * v)).round();
      for (var k = 0; k < foglie; k++) {
        final rf = math.Random(r * 100 + k + 1);
        final t = 0.18 + 0.82 * (k + 0.5) / foglie;
        // Rametti corti: le foglie riempiono il volume attorno al ramo.
        final base =
            ramo(t) +
            V3(
                  rf.nextDouble() - 0.5,
                  (rf.nextDouble() - 0.5) * 0.6,
                  rf.nextDouble() - 0.5,
                ) *
                0.22;
        final tangente = (ramo(math.min(t + 0.03, 1)) - base).normalizzato();
        final lato =
            V3.su.cross(tangente).normalizzato() * (k.isEven ? 1.0 : -1.0);
        final dir =
            (tangente * 0.35 +
                    lato * 0.75 +
                    V3.su * (0.05 - 0.9 * w + (rf.nextDouble() - 0.5) * 0.5))
                .normalizzato();
        final nuova = t > 0.85 && v > 0.55;
        final lunghezzaFoglia =
            (0.32 + 0.1 * v) *
            (0.85 + 0.3 * rf.nextDouble()) *
            (nuova ? 0.75 : 1) *
            (1 - 0.25 * s.secchezza);
        final attaccoFoglia = base + dir * 0.03;
        c.foglia(
          Foglia(
            picciolo: base,
            base: attaccoFoglia,
            controllo: attaccoFoglia + dir * (lunghezzaFoglia * 0.5),
            punta:
                attaccoFoglia +
                dir * lunghezzaFoglia +
                V3.su * (-lunghezzaFoglia * (0.25 + 0.3 * w)),
            larghezza: 0.24,
            forma: Forma.ellittica,
            rollio: (rf.nextDouble() - 0.5) * 2,
            eta: 0.3 * q + 0.7 * t,
            seme: r * 100 + k + 1,
            nuova: nuova,
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Chioma fitta di foglioline lucide e verde brillante, rami leggermente ricadenti.',
      fare: 'Luce intensa ma indiretta, sempre nello stesso posto; acqua quando i primi 2-3 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Rami pieni e tante foglie nuove verde chiaro sulle punte.',
      fare: 'Continua così; da marzo a settembre concima ogni 2-4 settimane.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie che ingialliscono e cadono, terriccio sempre umido.',
      fare: 'Lascia asciugare i primi 2-3 cm di terriccio prima di annaffiare e svuota il sottovaso dopo 15 minuti.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie gialle e scure che cadono in massa, rami che si svuotano, terriccio bagnato che sa di stantio.',
      fare: 'Sfila la pianta dal vaso, taglia le radici scure e molli e rinvasa in terriccio nuovo e drenante.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie secche e accartocciate che cadono ancora verdi, terriccio staccato dal vaso.',
      fare: 'Annaffia a fondo finché l\'acqua esce dai fori, poi controlla il terriccio più spesso.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Chioma rada, rami lunghi e spogli, foglie piccole e opache.',
      fare: 'Spostalo vicino a una finestra luminosa a est o a ovest, e poi non spostarlo più.',
    ),
    Scenario.troppoSole: (
      vedi: 'Macchie chiare e secche sulle foglie esposte al sole del pomeriggio.',
      fare: 'Va bene solo il sole del mattino: allontanalo dal vetro nelle ore calde.',
    ),
    Scenario.freddo: (
      vedi: 'Caduta improvvisa di molte foglie, anche verdi, dopo uno spostamento o una corrente d\'aria.',
      fare: 'Tienilo sopra i 16 °C, lontano da spifferi e termosifoni, e lascialo fermo: ricaccia in poche settimane.',
    ),
  };
}

/// Ficus robusta (Ficus elastica): fusti eretti con grandi foglie ovali,
/// spesse e lucide, e la guaina rossa sulla punta che protegge la foglia
/// nuova.
class FicusRobusta extends Specie {
  const FicusRobusta();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.2, alto: 5.35, basso: -2.1);

  @override
  Vaso get vaso => const Vaso(colore: Vaso.antracite, lucido: true);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF24472A),
    nuova: Color(0xFF6E7F3A),
    retro: Color(0xFF6F8A5E),
  );

  @override
  double get lucentezza => 1;

  @override
  bool get marciumeAMacchie => true;

  static const _fusti = [
    (x: -0.12, z: 0.06, altezza: 3.9, pendenza: V3(0.1, 0, -0.06), foglie: 11),
    (x: 0.2, z: -0.12, altezza: 2.8, pendenza: V3(0.25, 0, 0.12), foglie: 8),
    (x: -0.05, z: -0.25, altezza: 1.7, pendenza: V3(-0.2, 0, -0.25), foglie: 5),
  ];

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    for (var i = 0; i < _fusti.length; i++) {
      final f = _fusti[i];
      final base = V3(f.x, -0.05, f.z);
      final pendenza = f.pendenza * (1 + 0.8 * w);
      V3 fusto(double t) =>
          base + V3.su * (f.altezza * t) + pendenza * (t * t * f.altezza * 0.5);
      c.fusto(
        [for (var k = 0; k <= 10; k++) fusto(k / 10)],
        spessore: 0.09,
        spessoreFinale: 0.045,
        colore: const Color(0xFF6B6A45),
      );

      // Con poca luce le foglie basse cadono e il fusto resta spoglio.
      final inizio = 0.2 + 0.4 * (1 - v);
      final n = (f.foglie * (0.5 + 0.5 * v)).round();
      for (var k = 0; k < n; k++) {
        final rf = math.Random(i * 50 + k + 3);
        final t = inizio + (0.95 - inizio) * k / math.max(1, n - 1);
        final punto = fusto(t);
        final radiale = V3.cilindro(i * 1.3 + k * _angoloAureo, 1, 0);
        final nuova = k == n - 1 && v > 0.5;
        final lunghezza =
            (0.75 + 0.4 * v) *
            (0.85 + 0.25 * rf.nextDouble()) *
            (nuova ? 0.6 : 1) *
            (1 - 0.15 * s.secchezza);
        final su = -0.3 + 1.0 * t - 1.3 * w + (nuova ? 0.8 : 0);
        final dir = (radiale + V3.su * su).normalizzato();
        final attacco = punto + dir * 0.16;
        c.foglia(
          Foglia(
            picciolo: punto,
            base: attacco,
            controllo:
                attacco + dir * (lunghezza * 0.5) + V3.su * (lunghezza * 0.04),
            punta:
                attacco +
                dir * lunghezza +
                V3.su * (-lunghezza * (0.12 + 0.35 * w)),
            larghezza: 0.34,
            forma: Forma.ovale,
            rollio: (rf.nextDouble() - 0.5) * 1.1,
            motivo: Motivo.robusta,
            eta: t,
            seme: i * 50 + k + 3,
            nuova: nuova,
            coppa: 0.15,
          ),
        );
      }

      // Guaina rossa in cima, segno che sta per aprirsi una foglia nuova.
      if (v > 0.35) {
        final cima = fusto(1);
        final dir = (V3.su + pendenza * 0.4).normalizzato();
        c.foglia(
          Foglia(
            base: cima,
            controllo: cima + dir * 0.13,
            punta: cima + dir * (0.25 + 0.15 * v),
            larghezza: 0.12,
            forma: Forma.guaina,
            motivo: Motivo.nessuno,
            eta: 1,
            seme: i * 50 + 49,
            colore: const Color(0xFFA8443A),
            coppa: 0.6,
            sintomi: const Sintomi(),
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Grandi foglie ovali verde scuro, spesse e lucide, distribuite lungo il fusto.',
      fare: 'Luce intensa indiretta; acqua quando i primi 3-5 cm di terriccio sono asciutti. Pulisci le foglie con un panno umido.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Foglie nuove che si aprono dalla guaina rossa in cima ai fusti.',
      fare: 'Concima ogni 3-4 settimane da marzo a settembre; in primavera puoi cimare la punta per farla ramificare.',
    ),
    Scenario.troppaAcqua: (
      vedi:
          'Foglie basse che ingialliscono e cadono, terriccio sempre bagnato.',
      fare: 'Aspetta che i primi 3-5 cm di terriccio siano asciutti e svuota il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Macchie scure sulle foglie, foglie che cadono dal basso, terriccio fradicio.',
      fare: 'Togli la pianta dal vaso, elimina le radici marce e rinvasa in terriccio drenante con corteccia o perlite.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie che pendono verso il basso, si accartocciano e seccano ai bordi.',
      fare: 'Annaffia a fondo e lascia sgocciolare; le foglie tornano sode in un giorno o due.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Fusto lungo e spoglio in basso, poche foglie più piccole in cima.',
      fare: 'Avvicinala a una finestra luminosa; in primavera cima la punta per farla infoltire.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare e secche sulle foglie rivolte verso il vetro.',
      fare: 'Sole solo al mattino: d\'estate allontanala dalla finestra a sud nelle ore calde.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono all\'improvviso e colori spenti.',
      fare: 'Tienila sopra i 16 °C, lontano da porte aperte e da correnti fredde.',
    ),
  };
}

/// Ficus lyrata: tronco dritto con le foglie concentrate in alto, enormi,
/// ondulate e a forma di violino, con nervature chiare.
class FicusLyrata extends Specie {
  const FicusLyrata();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.3, alto: 6.0, basso: -2.1);

  @override
  Vaso get vaso => const Vaso(colore: Vaso.ceramicaChiara, lucido: true);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3A7530),
    nuova: Color(0xFF86B84E),
    retro: Color(0xFF8FAF6C),
  );

  @override
  double get lucentezza => 0.55;

  @override
  bool get marciumeAMacchie => true;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    const altezza = 3.9;
    // Con poca luce il fusto si piega verso la finestra.
    final piega = 0.15 + 0.45 * (1 - v);
    V3 tronco(double t) => V3(
      -piega * t * t + 0.04 * math.sin(t * 4),
      -0.05 + altezza * t * (1 - 0.06 * w),
      0.05 * math.sin(t * 3),
    );
    c.fusto(
      [for (var i = 0; i <= 12; i++) tronco(i / 12)],
      spessore: 0.11,
      spessoreFinale: 0.05,
      colore: const Color(0xFF8A7D6A),
    );

    final inizio = 0.38 + 0.3 * (1 - v);
    final n = (14 * (0.5 + 0.5 * v)).round();
    for (var k = 0; k < n; k++) {
      final rf = math.Random(k + 21);
      final t = inizio + (0.97 - inizio) * k / math.max(1, n - 1);
      final punto = tronco(t);
      final radiale = V3.cilindro(k * _angoloAureo + 0.4, 1, 0);
      final nuova = k >= n - 2 && v > 0.5;
      final lunghezza =
          (0.95 + 0.5 * v) *
          (0.85 + 0.25 * rf.nextDouble()) *
          (nuova ? 0.65 : 1) *
          (1 - 0.15 * s.secchezza);
      final su = 0.1 + 0.6 * t - 1.3 * w + (nuova ? 0.7 : 0);
      final dir = (radiale + V3.su * su).normalizzato();
      final attacco = punto + dir * 0.08;
      // Leggera torsione: le foglie del lyrata non sono mai piatte.
      final torsione = (rf.nextDouble() - 0.5) * 1.4;
      c.foglia(
        Foglia(
          picciolo: punto,
          base: attacco,
          controllo:
              attacco + dir * (lunghezza * 0.5) + V3.su * (lunghezza * 0.1),
          punta:
              attacco +
              dir * lunghezza +
              V3.su * (-lunghezza * (0.08 + 0.35 * w)),
          larghezza: 0.36,
          forma: Forma.violino,
          motivo: Motivo.lyrata,
          eta: t,
          seme: k + 21,
          nuova: nuova,
          rollio: torsione,
          coppa: 0.3,
        ),
      );
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie enormi a forma di violino, ondulate, con le nervature chiare ben in vista.',
      fare: 'Vicino a una grande finestra luminosa; ruotalo di un quarto ogni mese e non spostarlo.',
    ),
    Scenario.rigogliosa: (
      vedi:
          'Foglie nuove grandi e verde chiaro in cima, fusto robusto e dritto.',
      fare: 'Concima ogni 2-4 settimane da marzo a settembre con un concime ricco di azoto a metà dose.',
    ),
    Scenario.troppaAcqua: (
      vedi:
          'Macchie marroni scure al centro delle foglie, foglie basse gialle.',
      fare: 'Dirada le annaffiature: aspetta che i primi 3-5 cm di terriccio siano asciutti e controlla i fori del vaso.',
    ),
    Scenario.marciume: (
      vedi: 'Grandi macchie scure che si allargano, foglie che cadono dal basso, terriccio fradicio.',
      fare: 'Sfila la zolla, taglia le radici marce e rinvasa in terriccio drenante con corteccia e perlite.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Bordi delle foglie marroni e secchi, foglie che pendono.',
      fare: 'Annaffia a fondo e lascia sgocciolare, poi controlla il terriccio ogni settimana.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Foglie nuove piccole, fusto che si piega verso la finestra, foglie basse che cadono.',
      fare: 'Portalo vicino alla finestra più luminosa e ruotalo regolarmente.',
    ),
    Scenario.troppoSole: (
      vedi: 'Macchie chiare e secche sulle foglie, soprattutto dopo uno spostamento al sole.',
      fare: 'Abitualo al sole gradualmente; d\'estate riparalo dal sole delle ore calde.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono dopo una corrente fredda o uno sbalzo di temperatura.',
      fare: 'Tienilo sopra i 18 °C, lontano da porte, finestre aperte e termosifoni.',
    ),
  };
}
