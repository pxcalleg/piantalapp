import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'fiori.dart';

/// Kalanchoe: cespuglietto di fusti corti con foglie carnose a smerli,
/// opposte a croce, e mazzetti fitti di piccoli fiori rossi in cima.
class Kalanchoe extends Specie {
  const Kalanchoe();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.9, alto: 2.05, basso: -1.55);

  @override
  Vaso get vaso => const Vaso(altezza: 1.0, raggioFondo: 0.78);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2E5C2B),
    nuova: Color(0xFF4F8A3A),
    retro: Color(0xFF5F8550),
  );

  @override
  double get lucentezza => 0.8;

  @override
  double get quotaATerra => 0.6;

  static const _fiore = Color(0xFFD9283C);

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    // Con poca luce i fusti si allungano e le foglie si diradano.
    final filata = 1 - v;
    const fusti = 7;
    for (var k = 0; k < fusti; k++) {
      final rnd = math.Random(k + 53);
      final angolo = k * 2 * math.pi / fusti + rnd.nextDouble() * 0.5;
      final radiale = V3.cilindro(angolo, 1, 0);
      final centrale = k < 2;
      final base = V3.cilindro(angolo, centrale ? 0.08 : 0.32, -0.05);
      final altezza =
          (centrale ? 0.65 : 0.45 + 0.15 * rnd.nextDouble()) *
          (0.85 + 0.9 * filata);
      final apertura =
          (centrale ? 0.12 : 0.55 + 0.2 * rnd.nextDouble()) + 0.3 * w;
      V3 punto(double t) => c.fuoriDalVaso(
        base +
            radiale * (altezza * math.sin(apertura) * t) +
            V3.su * (altezza * math.cos(apertura) * t - 0.25 * w * t * t),
      );
      c.fusto(
        [for (var i = 0; i <= 6; i++) punto(i / 6)],
        spessore: 0.05,
        spessoreFinale: 0.04,
        colore: const Color(0xFF5C7A3A),
        marcisce: true,
      );

      // Coppie di foglie opposte, ogni coppia ruotata di 90 gradi.
      final coppie = (2 + 2 * v).round();
      for (var j = 0; j < coppie; j++) {
        final t = 0.3 + 0.7 * j / math.max(1, coppie - 1);
        final attacco = punto(t);
        for (final verso in const [0.0, math.pi]) {
          final seme = k * 20 + j * 2 + (verso > 0 ? 1 : 0);
          final a = angolo + j * math.pi / 2 + verso + 0.4;
          final dir =
              (V3.cilindro(a, 1, 0) * 0.85 +
                      radiale * 0.3 +
                      V3.su * (0.3 - 0.7 * w))
                  .normalizzato();
          final nuova = j == coppie - 1 && v > 0.6;
          final l =
              (0.42 + 0.08 * rnd.nextDouble()) *
              (0.7 + 0.4 * v) *
              (nuova ? 0.65 : 1) *
              (1 - 0.15 * s.secchezza);
          final inizio = attacco + dir * 0.04;
          c.foglia(
            Foglia(
              picciolo: attacco,
              base: inizio,
              controllo: inizio + dir * (l * 0.5) + V3.su * (l * 0.05),
              punta: inizio + dir * l - V3.su * (l * (0.08 + 0.35 * w)),
              larghezza: 0.42,
              forma: Forma.smerlata,
              motivo: Motivo.centrale,
              eta: t * 0.85,
              seme: seme,
              nuova: nuova,
              coppa: 0.3,
            ),
          );
        }
      }

      // Mazzetto di fiori su un breve stelo; con poca luce non fiorisce.
      if (v < 0.35) continue;
      final cima = punto(1);
      final stelo =
          cima + V3.su * (0.32 - 0.15 * w) + radiale * (0.06 + 0.2 * w);
      c.fusto(
        [cima, cima.medio(stelo) + radiale * 0.02, stelo],
        spessore: 0.02,
        colore: const Color(0xFF6E8A44),
      );
      final quanti = (8 + 10 * v).round();
      for (var i = 0; i < quanti; i++) {
        final r = 0.17 * math.sqrt((i + 0.5) / quanti);
        final a = i * 2.39996;
        final cupola = 0.06 * (1 - (r / 0.17) * (r / 0.17));
        final centro =
            stelo + V3.cilindro(a, r, 0.04 + cupola - 0.08 * w * r / 0.17);
        final seme = 500 + k * 30 + i;
        final m = c.sintomi(seme, 0.3 + 0.6 * r / 0.17);
        final fronte = (V3.su + V3.cilindro(a, r * 3, 0)).normalizzato();
        fiore(
          c,
          centro: centro,
          fronte: fronte,
          alto: radiale,
          seme: seme,
          sintomi: m,
          petali: [
            for (var p = 0; p < 4; p++)
              Petalo(
                angolo: p * math.pi / 2 + a,
                lunghezza: 0.055,
                larghezza: 0.5,
                colore: _fiore,
                coppa: 0.3,
              ),
          ],
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie carnose, lucide e sode, mazzetti fitti di fiori rossi sopra il cespuglio.',
      fare: 'Molta luce, anche qualche ora di sole; acqua solo quando il terriccio è asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Cespuglio compatto e pieno di foglie, tanti mazzetti di fiori.',
      fare: 'Togli i fiori secchi; per rifiorire vuole giornate corte: da ottobre 6 settimane con 14 ore di buio ogni notte.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle e molli, base dei fusti che si scurisce.',
      fare: 'È una pianta grassa: lascia asciugare del tutto il terriccio e svuota il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Fusti neri e molli alla base, foglie che cadono, muffa sul terriccio.',
      fare: 'Taglia le cime ancora sane, falle asciugare un giorno e piantale in terriccio per piante grasse.',
    ),
    Scenario.pocaAcqua: (
      vedi:
          'Foglie raggrinzite e più sottili che si piegano, fiori che seccano.',
      fare: 'Annaffia a fondo una volta: in un paio di giorni le foglie tornano sode.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Fusti lunghi e deboli, foglie rade e nessun fiore.',
      fare: 'Spostala vicino a una finestra a sud o ovest; i fusti filati si possono accorciare.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie arrossate ai bordi con chiazze chiare e secche.',
      fare: 'Abituala al sole un po\' alla volta e riparala nelle ore più calde d\'estate.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie spente, molli e qualcuna che cade.',
      fare: 'Tienila sopra i 10 °C e all\'asciutto; d\'estate può stare in balcone.',
    ),
  };
}
