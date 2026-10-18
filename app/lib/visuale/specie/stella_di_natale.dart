import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'fiori.dart';

/// Stella di Natale: alcuni fusti con foglie verdi e, in cima, una rosetta
/// di brattee rosse con al centro i piccoli fiori gialli (ciazi).
class StellaDiNatale extends Specie {
  const StellaDiNatale();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.3, alto: 2.9, basso: -1.85);

  @override
  Vaso get vaso => const Vaso(
    altezza: 1.2,
    raggioFondo: 0.78,
    colore: Vaso.ceramicaChiara,
    lucido: true,
  );

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2F5A2A),
    nuova: Color(0xFF4C7E36),
    retro: Color(0xFF6A8A55),
  );

  @override
  double get lucentezza => 0.35;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    // Con poca luce le brattee restano poche e sbiadite.
    final rosso = Color.lerp(
      const Color(0xFFC8122E),
      const Color(0xFF9A5A44),
      (0.75 * s.spente + 0.6 * (0.5 - v)).clamp(0.0, 1.0),
    )!;
    const fusti = 5;
    for (var k = 0; k < fusti; k++) {
      final rnd = math.Random(k + 17);
      final angolo = k * 2 * math.pi / fusti + rnd.nextDouble() * 0.4;
      final radiale = V3.cilindro(angolo, 1, 0);
      final centrale = k == 0;
      final base = V3.cilindro(angolo, centrale ? 0.05 : 0.3, -0.05);
      final altezza =
          (centrale ? 1.45 : 1.15 + 0.25 * rnd.nextDouble()) *
          (0.85 + 0.2 * (1 - v));
      final apertura =
          (centrale ? 0.05 : 0.38 + 0.1 * rnd.nextDouble()) + 0.35 * w;
      V3 punto(double t) => c.fuoriDalVaso(
        base +
            radiale * (altezza * math.sin(apertura) * t) +
            V3.su *
                (altezza * math.cos(apertura) * t - altezza * 0.35 * w * t * t),
      );
      c.fusto(
        [for (var i = 0; i <= 8; i++) punto(i / 8)],
        spessore: 0.045,
        spessoreFinale: 0.03,
        colore: const Color(0xFF5E7A3C),
        marcisce: true,
      );

      // Foglie verdi alterne lungo il fusto, con il picciolo.
      final foglie = (4 + 3 * v).round();
      for (var i = 0; i < foglie; i++) {
        final t = 0.25 + 0.6 * i / foglie;
        final attacco = punto(t);
        final seme = k * 20 + i;
        final a = angolo + i * 2.39996;
        final dir =
            (V3.cilindro(a, 1, 0) * 0.85 +
                    radiale * 0.35 +
                    V3.su * (0.2 - 0.9 * w))
                .normalizzato();
        final inizio = attacco + dir * 0.14;
        final l =
            (0.5 + 0.15 * rnd.nextDouble()) *
            (0.8 + 0.3 * v) *
            (1 - 0.15 * s.secchezza);
        c.foglia(
          Foglia(
            picciolo: attacco,
            base: inizio,
            controllo: inizio + dir * (l * 0.5) + V3.su * (l * 0.05),
            punta: inizio + dir * l - V3.su * (l * (0.15 + 0.45 * w)),
            larghezza: 0.36,
            forma: Forma.ellittica,
            motivo: Motivo.robusta,
            eta: t * 0.8,
            seme: seme,
            coppa: 0.2,
          ),
        );
      }

      // Rosetta di brattee in cima.
      final cima = punto(1);
      final brattee = (5 + 5 * v).round();
      for (var i = 0; i < brattee; i++) {
        final interna = i >= brattee * 0.6;
        final a = angolo + i * 2.39996;
        final seme = 400 + k * 20 + i;
        final m = c.sintomi(seme, interna ? 0.9 : 0.5);
        final dir =
            (V3.cilindro(a, 1, 0) + V3.su * ((interna ? 0.6 : 0.15) - 0.8 * w))
                .normalizzato();
        final l =
            (interna ? 0.32 : 0.55 + 0.12 * rnd.nextDouble()) *
            (0.85 + 0.2 * v);
        c.foglia(
          Foglia(
            base: cima,
            controllo: cima + dir * (l * 0.5) + V3.su * (l * 0.06),
            punta: cima + dir * l - V3.su * (l * (0.1 + 0.4 * w)),
            larghezza: 0.3,
            forma: Forma.ellittica,
            motivo: Motivo.robusta,
            eta: interna ? 0.9 : 0.5,
            seme: seme,
            colore: rosso,
            coppa: 0.25,
            sintomi: m,
          ),
        );
      }
      // Ciazi: piccoli fiori gialli e verdi al centro.
      for (var i = 0; i < 6; i++) {
        final a = i * 2.39996;
        final p = cima + V3.cilindro(a, 0.035 + 0.02 * (i % 2), 0.03);
        puntino(
          c,
          p,
          V3.su,
          0.025,
          i.isEven ? const Color(0xFFE2C23A) : const Color(0xFF9DAA3A),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Brattee rosso vivo in cima, foglie verdi e sode, piccoli fiori gialli al centro.',
      fare: 'Stanza luminosa a 18-22 °C senza sole diretto; acqua quando la superficie del terriccio è asciutta.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Fusti pieni di foglie e grandi rosette di brattee ben colorate.',
      fare: 'Per farla ricolorare l\'anno dopo: da fine settembre 14 ore di buio completo ogni notte per 8 settimane.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie basse gialle che cadono, terriccio sempre bagnato.',
      fare: 'Non lasciare mai acqua nel sottovaso o nell\'incarto decorativo: è la causa più comune di morte.',
    ),
    Scenario.marciume: (
      vedi: 'Fusti scuri alla base, pianta molle che perde foglie e brattee.',
      fare: 'Togli le radici marce e rinvasa in terriccio nuovo e drenante; annaffia poco finché non si riprende.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Tutta la pianta afflosciata, foglie e brattee che pendono e seccano ai bordi.',
      fare: 'Annaffia a fondo e lascia sgocciolare; non farla appassire spesso, perde le foglie.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Poche brattee sbiadite e fusti allungati con foglie rade.',
      fare: 'Mettila vicino alla finestra più luminosa di casa, senza sole diretto.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare e secche su foglie e brattee.',
      fare: 'Luce intensa sì, ma filtrata da una tenda.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono di colpo, anche verdi: ha preso freddo o una corrente.',
      fare: 'Sotto i 13 °C soffre: portala a casa ben incartata e tienila lontano da porte e finestre aperte.',
    ),
  };
}
