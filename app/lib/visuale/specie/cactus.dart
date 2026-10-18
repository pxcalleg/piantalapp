import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'grasse_comune.dart';

/// Mammillaria: cactus a palla con spine bianche e una corona di piccoli
/// fiori rosa in cima. Il globo è fatto di costole disegnate come lamine
/// curve attorno all'asse.
class Mammillaria extends Specie {
  const Mammillaria();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.6, alto: 1.95, basso: -1.6);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF4F7A45),
    nuova: Color(0xFF5E8A4E),
    retro: Color(0xFF5E7E52),
  );

  @override
  double get lucentezza => 0.25;

  @override
  bool get foglieCadono => false;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final f = filata(s);
    final g = gelo(s);
    // Il marciume lo fa accasciare di lato.
    final inclina = (s.marciume - 0.4).clamp(0.0, 1.0) * 0.9;
    globo(
      c,
      s,
      centro: const V3(0, 0, 0),
      raggio: 0.62 * (0.85 + 0.25 * s.vigore) * (1 - 0.12 * s.secchezza),
      // Con poca luce la cima si allunga, stretta e pallida.
      allunga: 1 + 0.9 * f,
      inclina: inclina,
      fiori: f > 0.3 || g > 0.5 || s.marciume > 0.5
          ? 0
          : (4 + 7 * s.vigore).round(),
      semeBase: 7,
    );
    // Rigogliosa: polloni attorno alla base.
    if (s.vigore > 0.85) {
      for (var i = 0; i < 3; i++) {
        globo(
          c,
          s,
          centro: V3.cilindro(0.5 + i * 2.2, 0.72, -0.02),
          raggio: 0.24,
          allunga: 1,
          inclina: 0,
          fiori: 0,
          semeBase: 200 + i * 30,
        );
      }
    }
  }

  void globo(
    Costruttore c,
    StatoPianta s, {
    required V3 centro,
    required double raggio,
    required double allunga,
    required double inclina,
    required int fiori,
    required int semeBase,
  }) {
    final r = raggio;
    final costole = 15;
    final cima =
        centro +
        V3.su * (1.55 * r * allunga * (1 - 0.25 * inclina)) +
        versoLuce * (0.35 * r * (allunga - 1)) +
        const V3(0.8, 0, -0.3) * (r * 1.2 * inclina);
    V3 punto(double angolo, double t) {
      final base = centro + V3.cilindro(angolo, 0.5 * r, -0.05);
      final controllo =
          centro +
          V3.cilindro(angolo, 1.45 * r, 1.4 * r * allunga) +
          const V3(0.8, 0, -0.3) * (r * 0.6 * inclina);
      return V3.bezier(base, controllo, cima, t);
    }

    for (var k = 0; k < costole; k++) {
      final seme = semeBase + k;
      final angolo = k * 2 * math.pi / costole;
      final m = sintomiGrasse(c, s, seme, (k * 0.37) % 1);
      c.foglia(
        Foglia(
          base: punto(angolo, 0),
          controllo:
              centro +
              V3.cilindro(angolo, 1.45 * r, 1.4 * r * allunga) +
              const V3(0.8, 0, -0.3) * (r * 0.6 * inclina),
          punta: cima,
          larghezza: 0.15 * (1 - 0.25 * s.secchezza) / math.sqrt(allunga),
          forma: Forma.ovale,
          motivo: Motivo.cactus,
          eta: 0.5,
          seme: seme,
          lato: V3(-math.sin(angolo), 0, math.cos(angolo)),
          coppa: -0.3,
          sintomi: Sintomi(
            gialla: m.gialla,
            secca: m.secca * 0.6,
            // Il marciume sale dalla base di tutte le costole.
            marcia: math.max(s.marciume * 0.55, m.marcia * 0.8),
            bruciata: m.bruciata,
            variegatura: m.variegatura,
          ),
        ),
      );
    }

    // Corona di fiorellini rosa attorno alla cima.
    for (var i = 0; i < fiori; i++) {
      final angolo = i * 2 * math.pi / fiori + 0.3;
      final centroFiore = punto(angolo, 0.8);
      final fuori = (centroFiore - cima).normalizzato();
      final normale = (fuori * 0.6 + V3.su * 0.8).normalizzato();
      var lato = normale.cross(V3.su);
      if (lato.lunghezza < 0.1) lato = const V3(1, 0, 0);
      lato = lato.normalizzato();
      final avanti = lato.cross(normale).normalizzato();
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        final dir = (lato * math.cos(a) + avanti * math.sin(a) + normale * 0.7)
            .normalizzato();
        final l = 0.13 * (r / 0.62);
        c.foglia(
          Foglia(
            base: centroFiore,
            controllo: centroFiore + dir * (l * 0.5),
            punta: centroFiore + dir * l,
            larghezza: 0.42,
            forma: Forma.lanceolata,
            motivo: Motivo.nessuno,
            eta: 1,
            seme: 900 + i * 6 + p,
            colore: p.isEven
                ? const Color(0xFFE2559B)
                : const Color(0xFFEC79B1),
            coppa: 0.2,
            sintomi: const Sintomi(),
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Palla verde soda, coperta di spine bianche a stella, con una corona di fiorellini rosa in cima.',
      fare: 'Più luce possibile, anche sole diretto; acqua solo quando il terriccio è asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Corona fitta di fiori e piccoli polloni a palla che spuntano attorno.',
      fare: 'Per farla fiorire serve un inverno fresco (8-12 °C) e asciutto, poi sole in primavera.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Base che ingiallisce e si ammorbidisce, terriccio sempre bagnato.',
      fare: 'Smetti di annaffiare subito e lascia asciugare del tutto; usa terriccio per cactus molto drenante.',
    ),
    Scenario.marciume: (
      vedi: 'Base marrone scura e molle che sale lungo la palla; la pianta si accascia di lato.',
      fare: 'Se la parte alta è sana tagliala sopra il marcio, lasciala asciugare settimane e ripiantala. Altrimenti è persa.',
    ),
    Scenario.pocaAcqua: (
      vedi:
          'Palla più piccola e raggrinzita, costole più marcate, nessun fiore.',
      fare: 'Annaffia a fondo una volta in primavera o estate: in pochi giorni torna gonfia.',
    ),
    Scenario.pocaLuce: (
      vedi: 'La cima si allunga stretta e pallida verso la finestra e non fa fiori.',
      fare: 'Mettila sul davanzale più soleggiato. La parte filata resta così, la crescita nuova torna compatta.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare o giallo-brune sul lato esposto dopo un passaggio brusco al sole.',
      fare: 'Il sole lo ama, ma dopo l\'inverno in casa va abituato gradualmente.',
    ),
    Scenario.freddo: (
      vedi: 'Costole che si scuriscono e diventano molli, colore spento, niente fiori.',
      fare: 'D\'inverno fresco va bene (sopra i 5 °C), ma sempre all\'asciutto: il freddo umido è il vero pericolo.',
    ),
  };
}

/// Opuntia microdasys, fico d'India nano o «orecchie di coniglio»: pale
/// piatte e ovali una sopra l'altra, punteggiate di ciuffi di glochidi.
class Opuntia extends Specie {
  const Opuntia();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.9, alto: 2.6, basso: -1.6);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF5E8F3C),
    nuova: Color(0xFF86B556),
    retro: Color(0xFF6F9A50),
  );

  @override
  double get lucentezza => 0.2;

  @override
  bool get foglieCadono => false;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final f = filata(s);
    final livelli = s.vigore > 0.85 ? 3 : 2;
    var seme = 13;
    void pala(V3 base, V3 dir, V3 lato, double l, int livello) {
      final rnd = math.Random(seme * 3 + 1);
      final mio = seme++;
      final eta = livello / 3;
      final m = sintomiGrasse(c, s, mio, eta);
      // Pala molle che si piega: marciume, gelo o sete.
      final piega =
          (m.marcia * ((s.marciume - 0.3) / 0.5).clamp(0.0, 1.0) * 0.8 +
                  0.25 * s.appassimento +
                  0.4 * gelo(s) * (1 - eta))
              .clamp(0.0, 1.0);
      final fuori = V3(dir.x, 0, dir.z).lunghezza < 0.05
          ? lato.orizzontale()
          : dir.orizzontale();
      var d = (dir + fuori * (0.8 * piega) + V3.su * (-0.9 * piega))
          .normalizzato();
      // Filata: si piega verso la finestra.
      d = (d + versoLuce * (0.35 * f)).normalizzato();
      final larghezza = 0.42 * (1 - 0.45 * f) * (1 - 0.2 * s.secchezza);
      final punta = c.fuoriDalVaso(base + d * l);
      c.foglia(
        Foglia(
          base: base,
          controllo: base + d * (l * 0.5),
          punta: punta,
          larghezza: larghezza,
          forma: Forma.ovalePiccola,
          motivo: Motivo.opuntia,
          eta: eta,
          seme: mio,
          nuova: livello == livelli - 1 && s.vigore > 0.6,
          lato: lato,
          coppa: 0.06 + 0.1 * s.secchezza,
          sintomi: Sintomi(
            gialla: m.gialla,
            secca: m.secca * 0.45,
            marcia: m.marcia * (0.45 + 0.55 * s.marciume),
            bruciata: m.bruciata,
            variegatura: m.variegatura,
          ),
        ),
      );
      if (livello + 1 >= livelli) return;
      final figli = f > 0.5 ? 1 : 2;
      final normale = d.cross(lato).normalizzato();
      final latoVero = normale.cross(d).normalizzato();
      for (var i = 0; i < figli; i++) {
        final verso = figli == 1 ? 0.3 : (i == 0 ? -1.0 : 1.0);
        const u = 0.82;
        final w = Forma.ovalePiccola.larghezzaA(u) * larghezza * l;
        final attacco =
            V3.bezier(base, base + d * (l * 0.5), punta, u) +
            latoVero * (verso * 0.55 * w);
        final th = verso * (0.55 + 0.2 * rnd.nextDouble());
        final dirFiglio = (d * math.cos(th) + latoVero * math.sin(th))
            .normalizzato();
        final giro = (rnd.nextDouble() - 0.5) * 1.6;
        final latoFiglio =
            dirFiglio.cross(normale).normalizzato() * math.cos(giro) +
            normale * math.sin(giro);
        pala(
          attacco,
          dirFiglio,
          latoFiglio,
          l * (0.72 + 0.1 * rnd.nextDouble()) * (1 + 0.3 * f),
          livello + 1,
        );
      }
    }

    pala(
      const V3(-0.12, -0.05, 0.05),
      const V3(-0.15, 1, 0.05),
      const V3(1, 0, 0.35),
      0.95 * (0.85 + 0.2 * s.vigore) * (1 + 0.35 * f),
      0,
    );
    pala(
      const V3(0.2, -0.05, -0.12),
      const V3(0.35, 1, -0.1),
      const V3(0.4, 0, 1),
      0.8 * (0.85 + 0.2 * s.vigore) * (1 + 0.35 * f),
      0,
    );
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Pale piatte, ovali e sode, verde brillante, punteggiate di ciuffetti gialli di glochidi.',
      fare: 'Sole diretto e terriccio per cactus; acqua solo quando è asciutto. Maneggiala con guanti: i glochidi pungono.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Nuove pale verde chiaro che spuntano sul bordo di quelle vecchie.',
      fare: 'Una pala staccata, lasciata asciugare qualche giorno e appoggiata sul terriccio, mette radici.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Pale giallastre e molli, che si scuriscono alla base.',
      fare: 'Smetti di annaffiare e lascia asciugare del tutto; vaso in terracotta con fori e niente sottovaso pieno.',
    ),
    Scenario.marciume: (
      vedi: 'Pale che si piegano e cadono, base scura e molle.',
      fare: 'Salva le pale sane come talee e butta la parte marcia con il terriccio.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Pale raggrinzite, più sottili e leggermente piegate.',
      fare:
          'Annaffia a fondo e lascia scolare: in pochi giorni tornano gonfie.',
    ),
    Scenario.pocaLuce: (
      vedi:
          'Pale nuove strette, allungate e pallide, piegate verso la finestra.',
      fare: 'Ha bisogno di sole: spostala sul davanzale più luminoso o fuori d\'estate.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare o giallo-brune sulle pale più esposte.',
      fare: 'Abituala gradualmente al sole pieno, soprattutto dopo l\'inverno in casa.',
    ),
    Scenario.freddo: (
      vedi: 'Pale con chiazze scure e molli che si afflosciano.',
      fare: 'D\'inverno tienila al fresco ma sopra i 5 °C e completamente asciutta.',
    ),
  };
}
