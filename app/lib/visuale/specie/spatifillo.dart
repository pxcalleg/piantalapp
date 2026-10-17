import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

/// Spatifillo: cespo di foglie lanceolate su lunghi piccioli e fiori a spata
/// bianca. Quando ha sete le foglie si afflosciano sul bordo del vaso.
class Spatifillo extends Specie {
  const Spatifillo();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.4, alto: 3.9, basso: -2.1);

  @override
  Vaso get vaso => const Vaso(colore: Vaso.ceramicaChiara, lucido: true);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF285C2C),
    nuova: Color(0xFF4F8A3A),
    retro: Color(0xFF6F9460),
  );

  @override
  double get lucentezza => 0.85;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    final n = (9 + 6 * v).round();
    for (var k = 0; k < n; k++) {
      final rnd = math.Random(k + 61);
      final angolo = k * 2.39996 + rnd.nextDouble() * 0.3;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.05 + 0.15 * rnd.nextDouble(), -0.06);
      final eta = rnd.nextDouble();
      final nuova = eta > 0.85 && v > 0.5;
      final lunghezza =
          (1.1 + 0.6 * rnd.nextDouble()) *
          (0.85 + 0.25 * v) *
          (nuova ? 0.8 : 1);
      final apertura = 0.25 + 0.4 * rnd.nextDouble() + 0.5 * w;
      final abbassa =
          lunghezza * (0.05 + 1.05 * w * (0.7 + 0.3 * rnd.nextDouble()));

      V3 picciolo(double t) => c.fuoriDalVaso(
        base +
            radiale * (lunghezza * math.sin(apertura) * t) +
            V3.su * (lunghezza * math.cos(apertura) * t - abbassa * t * t),
      );

      c.fusto(
        [for (var i = 0; i <= 8; i++) picciolo(i / 8)],
        spessore: 0.026,
        spessoreFinale: 0.018,
        colore: const Color(0xFF3E6B32),
        marcisce: true,
      );

      final attacco = picciolo(1);
      final tangente = (attacco - picciolo(0.9)).normalizzato();
      final dir = (tangente * 0.55 + radiale * 0.45 + V3.su * (0.25 - 1.1 * w))
          .normalizzato();
      final lunghezzaFoglia =
          (0.95 + 0.35 * v) *
          (0.85 + 0.3 * rnd.nextDouble()) *
          (1 - 0.15 * s.secchezza);
      c.foglia(
        Foglia(
          base: attacco,
          controllo:
              attacco +
              dir * (lunghezzaFoglia * 0.55) +
              V3.su * (lunghezzaFoglia * 0.12 * (1 - w)),
          punta: c.fuoriDalVaso(
            attacco +
                dir * lunghezzaFoglia +
                V3.su * (-lunghezzaFoglia * (0.22 + 0.5 * w)),
          ),
          larghezza: 0.25,
          rollio: (rnd.nextDouble() - 0.5) * 1.6,
          forma: Forma.lanceolata,
          motivo: Motivo.spatifillo,
          eta: eta,
          seme: k + 61,
          nuova: nuova,
          coppa: 0.3,
        ),
      );
    }

    // Fiori: con poca luce non ne fa.
    final fiori = v > 0.6
        ? 3
        : v > 0.4
        ? 2
        : v > 0.25
        ? 1
        : 0;
    for (var k = 0; k < fiori; k++) {
      final rnd = math.Random(k + 91);
      final angolo = k * 2.1 + 0.6;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.1, -0.06);
      final altezza = (2.3 + 0.4 * rnd.nextDouble()) * (0.85 + 0.15 * v);
      final apertura = 0.12 + 0.12 * rnd.nextDouble() + 0.5 * w;
      final abbassa = altezza * 1.0 * w;
      V3 stelo(double t) => c.fuoriDalVaso(
        base +
            radiale * (altezza * math.sin(apertura) * t) +
            V3.su * (altezza * math.cos(apertura) * t - abbassa * t * t),
      );
      c.fusto(
        [for (var i = 0; i <= 8; i++) stelo(i / 8)],
        spessore: 0.022,
        spessoreFinale: 0.016,
        colore: const Color(0xFF4D7A3C),
        marcisce: true,
      );
      final cima = stelo(1);
      final tangente = (cima - stelo(0.9)).normalizzato();
      final dir = (tangente * 0.7 + radiale * 0.3).normalizzato();
      final lato = V3.su.cross(radiale).normalizzato();
      final seme = 900 + k;
      final m = c.sintomi(seme, 0.6);
      c.foglia(
        Foglia(
          base: cima,
          controllo: cima + dir * 0.4 + radiale * 0.1,
          punta: cima + dir * 0.78 - radiale * 0.06,
          larghezza: 0.4,
          forma: Forma.spata,
          motivo: Motivo.nessuno,
          eta: 0.6,
          seme: seme,
          lato: lato,
          // La spata invecchiando diventa verdastra.
          colore: Color.lerp(
            const Color(0xFFF5F3EA),
            const Color(0xFFB9C98E),
            0.5 * s.spente + 0.5 * m.gialla,
          ),
          coppa: 0.55,
          sintomi: Sintomi(
            secca: m.secca,
            marcia: m.marcia,
            bruciata: m.bruciata,
          ),
        ),
      );
      // Spadice color crema davanti alla spata.
      final spadice = cima + radiale * 0.09 + dir * 0.05;
      c.fusto(
        [spadice, spadice + dir * 0.13, spadice + dir * 0.26],
        spessore: 0.07,
        spessoreFinale: 0.05,
        colore: const Color(0xFFE9DFB0),
      );
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie verde scuro lucide e dritte, fiori bianchi a spata.',
      fare: 'Luce media indiretta; acqua quando i primi 2 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Cespo folto, foglie nuove e diversi fiori bianchi aperti.',
      fare: 'Più luce indiretta e concime per piante da fiore a metà dose ogni mese, da marzo a settembre.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle e terriccio che sa di stantio.',
      fare: 'Aspetta che i primi 2 cm di terriccio siano asciutti e svuota il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie che anneriscono e si afflosciano anche con il terriccio bagnato.',
      fare: 'Sfila il cespo, taglia le radici marce, dividilo se serve e rinvasa in terriccio nuovo.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Tutte le foglie afflosciate sul bordo del vaso, punte secche e marroni.',
      fare: 'Annaffia a fondo: in poche ore si rialza. Usa acqua poco calcarea per evitare le punte marroni.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Foglie scure e allungate, nessun fiore.',
      fare: 'Spostalo in un punto più luminoso, senza sole diretto: tornerà a fiorire.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie schiarite con chiazze secche e bruciate.',
      fare: 'Niente sole diretto: basta una stanza luminosa.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie spente e mosce, qualche foglia che ingiallisce.',
      fare: 'Tienilo sopra i 18 °C, lontano da finestre aperte e spifferi.',
    ),
  };
}
