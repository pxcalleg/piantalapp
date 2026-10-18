import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'fiori.dart';

/// Stelo che parte da [base] e si piega verso [radiale]: [angolo] dà, per
/// ogni tratto da 0 a 1, l'inclinazione dalla verticale in radianti.
List<V3> _stelo(
  Costruttore c,
  V3 base,
  V3 radiale,
  double lunghezza,
  double Function(double t) angolo, {
  int tratti = 14,
}) {
  final punti = [base];
  var p = base;
  for (var i = 1; i <= tratti; i++) {
    final a = angolo((i - 0.5) / tratti);
    p =
        p +
        (V3.su * math.cos(a) + radiale * math.sin(a)) * (lunghezza / tratti);
    p = c.fuoriDalVaso(p);
    punti.add(p);
  }
  return punti;
}

V3 _lungo(List<V3> punti, double t) {
  final x = t.clamp(0.0, 1.0) * (punti.length - 1);
  final i = math.min(x.floor(), punti.length - 2);
  final f = x - i;
  return punti[i] * (1 - f) + punti[i + 1] * f;
}

// -------------------------------------------------------------- falenopsis

/// Phalaenopsis: poche foglie larghe e carnose a due a due, radici aeree
/// argentate fuori dal vaso e uno stelo ad arco con i fiori a farfalla.
class Falenopsis extends Specie {
  const Falenopsis();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.3, alto: 3.4, basso: -1.75);

  // Vaso chiaro e lucido, come quelli trasparenti per orchidee.
  @override
  Vaso get vaso => const Vaso(
    altezza: 1.2,
    raggioFondo: 0.8,
    colore: Color(0xFFD5DED9),
    lucido: true,
  );

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2E5A2B),
    nuova: Color(0xFF4F8A3C),
    retro: Color(0xFF5E6E45),
  );

  @override
  double get lucentezza => 0.75;

  static const _petalo = Color(0xFFF4C9E0);
  static const _labello = Color(0xFFB32D6E);

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;

    // Radici aeree: argentate se asciutte, verdi appena bagnate.
    final radice = Color.lerp(
      const Color(0xFFC9CDBF),
      const Color(0xFF7FA160),
      s.umiditaTerreno * (1 - s.marciume),
    )!;
    for (var k = 0; k < 4; k++) {
      final rnd = math.Random(k + 71);
      final a = k * 1.7 + 0.9 + rnd.nextDouble() * 0.4;
      final radiale = V3.cilindro(a, 1, 0);
      final lunghezza = 0.5 + 0.4 * rnd.nextDouble();
      c.fusto(
        [
          for (var i = 0; i <= 8; i++)
            () {
              final t = i / 8;
              final r = 0.15 + 1.0 * t;
              return c.fuoriDalVaso(
                radiale * r +
                    V3.su *
                        (0.08 +
                            0.18 * math.sin(math.pi * math.min(t * 1.3, 1)) -
                            lunghezza * math.max(0, t - 0.7) * 2.2),
              );
            }(),
        ],
        spessore: 0.04,
        spessoreFinale: 0.03,
        colore: radice,
        marcisce: true,
      );
    }

    // Foglie su due file opposte, le più vecchie in basso.
    final n = (4 + 3 * v).round();
    for (var k = 0; k < n; k++) {
      final rnd = math.Random(k + 11);
      final angolo = k * math.pi + (k ~/ 2) * 0.35 + rnd.nextDouble() * 0.2;
      final radiale = V3.cilindro(angolo, 1, 0);
      final eta = (k + 0.5) / n;
      final nuova = k == n - 1 && v > 0.5;
      final base = V3(0, 0.02 + 0.035 * k, 0) + radiale * 0.03;
      final lunghezza =
          (1.2 + 0.3 * rnd.nextDouble()) *
          (0.75 + 0.35 * v) *
          (nuova ? 0.55 : 1) *
          (1 - 0.12 * s.secchezza);
      final alzata = 0.3 + 0.35 * eta - 0.75 * w;
      c.foglia(
        Foglia(
          base: base,
          controllo:
              base +
              radiale * (lunghezza * 0.5) +
              V3.su * (lunghezza * (0.2 + 0.2 * eta) * (1 - w)),
          punta: c.fuoriDalVaso(
            base + radiale * lunghezza + V3.su * (lunghezza * (alzata - 0.2)),
          ),
          larghezza: 0.3,
          forma: Forma.ovale,
          eta: eta,
          seme: k + 11,
          nuova: nuova,
          coppa: 0.35,
          rollio: (rnd.nextDouble() - 0.5) * 0.4,
        ),
      );
    }

    // Steli fioriti: con poca luce non rifiorisce.
    final steli = v > 0.85 ? 2 : (v > 0.35 ? 1 : 0);
    for (var k = 0; k < steli; k++) {
      final angolo = 0.5 + k * 2.8;
      final radiale = V3.cilindro(angolo, 1, 0);
      final lunghezza = (2.6 + 0.3 * k) * (0.85 + 0.15 * v);
      final punti = _stelo(
        c,
        V3.cilindro(angolo, 0.08, 0.1),
        radiale,
        lunghezza,
        (t) =>
            0.08 +
            math.pow(math.max(0, (t - 0.35) / 0.65), 1.2) * (1.9 + 0.5 * w) +
            0.25 * w * t,
      );
      c.fusto(
        punti,
        spessore: 0.026,
        spessoreFinale: 0.018,
        colore: const Color(0xFF4E6A37),
      );
      // I fiori guardano di lato rispetto all'arco.
      final fronte =
          (radiale.cross(V3.su) * (k.isEven ? 1.0 : -1.0) + radiale * 0.35)
              .normalizzato();
      final fiori = v > 0.6 ? 6 : 4;
      for (var i = 0; i < fiori + 2; i++) {
        final t = 0.45 + 0.53 * i / (fiori + 1);
        final attacco = _lungo(punti, t);
        final seme = 300 + k * 20 + i;
        if (i >= fiori) {
          puntino(
            c,
            attacco,
            -V3.su,
            0.045 - 0.01 * (i - fiori),
            const Color(0xFF9DB06A),
          );
          continue;
        }
        final eta = 0.15 + 0.7 * i / fiori;
        final m = c.sintomi(seme, eta);
        final centro = attacco - V3.su * 0.2 + fronte * 0.06;
        c.fusto(
          [attacco, attacco - V3.su * 0.11 + fronte * 0.03, centro],
          spessore: 0.012,
          colore: const Color(0xFF5E7A45),
        );
        final scala = 1 - 0.18 * i / fiori;
        fiore(
          c,
          centro: centro,
          fronte: fronte + V3.su * 0.15,
          alto: V3.su,
          seme: seme,
          sintomi: m,
          scala: scala,
          petali: [
            const Petalo(
              angolo: 0,
              lunghezza: 0.3,
              larghezza: 0.3,
              colore: _petalo,
            ),
            const Petalo(
              angolo: 2.35,
              lunghezza: 0.3,
              larghezza: 0.3,
              colore: _petalo,
            ),
            const Petalo(
              angolo: -2.35,
              lunghezza: 0.3,
              larghezza: 0.3,
              colore: _petalo,
            ),
            const Petalo(
              angolo: 1.3,
              lunghezza: 0.34,
              larghezza: 0.55,
              colore: _petalo,
            ),
            const Petalo(
              angolo: -1.3,
              lunghezza: 0.34,
              larghezza: 0.55,
              colore: _petalo,
            ),
            const Petalo(
              angolo: math.pi,
              lunghezza: 0.2,
              larghezza: 0.42,
              colore: _labello,
              avanti: 0.4,
            ),
          ],
        );
        if (!m.cade) {
          puntino(
            c,
            centro + fronte * 0.03,
            fronte,
            0.02 * scala,
            const Color(0xFFE8C53A),
          );
        }
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie larghe, sode e lucide, radici argentate e uno stelo ad arco pieno di fiori.',
      fare: 'Luce intensa ma indiretta; acqua quando le radici nel vaso sono diventate argentate.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Foglie nuove al centro, radici verdi e sode e due steli fioriti.',
      fare: 'Concime per orchidee a dose ridotta ogni 2-3 settimane in crescita; a fine fioritura taglia lo stelo sopra il secondo nodo.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle e molli, radici scure nel vaso, qualche fiore che cade.',
      fare: 'Annaffia solo quando le radici sono argentate e non lasciare mai acqua nel coprivaso.',
    ),
    Scenario.marciume: (
      vedi: 'Radici marroni e molli, foglie che ingialliscono e si staccano dalla base.',
      fare: 'Sfila la pianta, taglia le radici marce e rinvasa in corteccia nuova per orchidee, in un vaso trasparente.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie mosce e raggrinzite che pendono, radici grigie e fiori che seccano.',
      fare: 'Immergi il vaso in acqua a temperatura ambiente per 10-15 minuti e lascialo sgocciolare bene.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Foglie scure e opache e nessuno stelo nuovo: non rifiorisce.',
      fare: 'Mettila vicino a una finestra luminosa, a est è perfetta; un calo di qualche grado di notte in autunno aiuta a rifiorire.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare e secche sulle foglie rivolte alla finestra.',
      fare: 'Niente sole diretto nelle ore calde: basta una tenda leggera.',
    ),
    Scenario.freddo: (
      vedi: 'Boccioli e fiori che cadono all\'improvviso, foglie spente.',
      fare: 'Tienila sopra i 16 °C, lontano da spifferi, termosifoni e finestre aperte d\'inverno.',
    ),
  };
}

// -------------------------------------------------------------- dendrobium

/// Dendrobium nobile: fasci di canne erette a nodi, foglie sulla parte alta
/// e fiori a coppie lungo le canne.
class Dendrobium extends Specie {
  const Dendrobium();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.1, alto: 3.4, basso: -1.75);

  @override
  Vaso get vaso => const Vaso(altezza: 1.15, raggioFondo: 0.78);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3B6A2D),
    nuova: Color(0xFF5E9440),
    retro: Color(0xFF6E8C55),
  );

  @override
  double get lucentezza => 0.5;

  static const _petalo = Color(0xFFEBC3E0);
  static const _labello = Color(0xFFF6EBCF);

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    final n = (5 + 3 * v).round();
    for (var k = 0; k < n; k++) {
      final rnd = math.Random(k + 23);
      final angolo = k * 2.39996 + rnd.nextDouble() * 0.3;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.08 + 0.3 * rnd.nextDouble(), -0.05);
      // Le canne vecchie hanno perso le foglie; l'ultima è la più giovane.
      final vecchia = k < 2;
      final giovane = k == n - 1 && v > 0.5;
      final altezza =
          (1.5 + 0.8 * rnd.nextDouble()) *
          (0.75 + 0.35 * v) *
          (giovane ? 0.6 : 1);
      final inclina = 0.1 + 0.12 * rnd.nextDouble() + 0.35 * w;
      final punti = _stelo(
        c,
        base,
        radiale,
        altezza,
        (t) => inclina * (0.5 + t),
        tratti: 8,
      );
      // Canne raggrinzite e gialle quando ha sete.
      final colore = Color.lerp(
        vecchia ? const Color(0xFFA9A658) : const Color(0xFF8EA64C),
        const Color(0xFFB59A55),
        0.6 * s.secchezza,
      )!;
      for (var i = 0; i < punti.length - 1; i++) {
        final t = i / (punti.length - 1);
        // Canna a clava: più grossa a metà.
        final spessore = 0.05 + 0.035 * math.sin(math.pi * (0.2 + 0.7 * t));
        c.fusto(
          [punti[i], punti[i + 1]],
          spessore: spessore * (1 - 0.25 * s.secchezza),
          spessoreFinale: spessore * (1 - 0.25 * s.secchezza),
          colore: colore,
          marcisce: true,
        );
        final nodo = punti[i + 1];
        c.fusto(
          [nodo - V3.su * 0.01, nodo + V3.su * 0.01],
          spessore: spessore + 0.012,
          colore: const Color(0xFF6E6F3A),
        );
      }
      final lato = V3.su.cross(radiale).normalizzato();
      // Foglie alterne sulla metà alta delle canne giovani.
      if (!vecchia) {
        for (var i = 4; i < punti.length; i++) {
          final seme = k * 30 + i;
          final eta = i / punti.length * (giovane ? 1 : 0.8);
          final verso = i.isEven ? 1.0 : -1.0;
          final dir =
              (lato * (0.8 * verso) + radiale * 0.35 + V3.su * (0.45 - 1.0 * w))
                  .normalizzato();
          final l =
              (0.42 + 0.1 * rnd.nextDouble()) *
              (0.8 + 0.3 * v) *
              (1 - 0.15 * s.secchezza);
          final attacco = punti[i];
          c.foglia(
            Foglia(
              base: attacco,
              controllo:
                  attacco + dir * (l * 0.5) + V3.su * (l * 0.08 * (1 - w)),
              punta: attacco + dir * l - V3.su * (l * (0.08 + 0.4 * w)),
              larghezza: 0.22,
              forma: Forma.ellittica,
              eta: eta,
              seme: seme,
              nuova: giovane,
              coppa: 0.3,
            ),
          );
        }
      }
      // Fiori a coppie dai nodi delle canne mature; con poca luce niente.
      if (giovane || v < 0.35) continue;
      for (var i = 2; i < punti.length - 1; i++) {
        if (rnd.nextDouble() > 0.15 + 0.35 * v) continue;
        for (final verso in const [1.0, -1.0]) {
          final seme = 600 + k * 30 + i * 2 + (verso > 0 ? 0 : 1);
          final m = c.sintomi(seme, 0.2 + 0.6 * i / punti.length);
          final attacco = punti[i];
          final fuori = (radiale * 0.8 + lato * (0.7 * verso)).normalizzato();
          final centro = attacco + fuori * 0.16 - V3.su * 0.03;
          c.fusto(
            [attacco, centro],
            spessore: 0.012,
            colore: const Color(0xFF8AA04E),
          );
          fiore(
            c,
            centro: centro,
            fronte: fuori + V3.su * 0.2,
            alto: V3.su,
            seme: seme,
            sintomi: m,
            petali: [
              for (final a in const [0.0, 2.2, -2.2])
                Petalo(
                  angolo: a,
                  lunghezza: 0.17,
                  larghezza: 0.28,
                  colore: _petalo,
                ),
              for (final a in const [1.15, -1.15])
                Petalo(
                  angolo: a,
                  lunghezza: 0.18,
                  larghezza: 0.42,
                  colore: _petalo,
                ),
              const Petalo(
                angolo: math.pi,
                lunghezza: 0.13,
                larghezza: 0.5,
                colore: _labello,
                avanti: 0.35,
              ),
            ],
          );
          if (!m.cade) {
            // Gola bordeaux al centro del labello.
            puntino(
              c,
              centro - V3.su * 0.04 + fuori * 0.03,
              fuori,
              0.025,
              const Color(0xFF5E1531),
            );
          }
        }
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Canne erette e sode, foglie verdi in alto e fiori rosa e bianchi lungo le canne.',
      fare: 'Molta luce, anche un po\' di sole al mattino; acqua quando il substrato è quasi asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Canne nuove alla base e tanti fiori a coppie sui nodi.',
      fare: 'In estate tienila fuori a mezz\'ombra e concima; da ottobre stop al concime e acqua ridotta, al fresco (10-15 °C) per farla fiorire.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle che cadono e canne molli alla base.',
      fare: 'Lascia asciugare il substrato tra un\'annaffiatura e l\'altra; d\'inverno basta poca acqua.',
    ),
    Scenario.marciume: (
      vedi: 'Canne nere e molli alla base, foglie gialle che si staccano.',
      fare: 'Togli dal vaso, elimina radici e canne marce e rinvasa in corteccia nuova in un vaso piccolo.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Canne raggrinzite e giallastre, foglie mosce, fiori secchi.',
      fare: 'Immergi il vaso in acqua per 10 minuti; in estate annaffia più spesso e nebulizza.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Canne sottili e nessun fiore.',
      fare: 'Ha bisogno di tanta luce: vicino a una finestra a sud o est, con sole del mattino.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie con chiazze chiare e secche dopo il sole forte di mezzogiorno.',
      fare: 'Il sole del mattino va bene, ma riparala nelle ore più calde d\'estate.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono e boccioli che si staccano.',
      fare: 'Il fresco d\'inverno le serve, ma non sotto i 10 °C e mai al gelo o nelle correnti.',
    ),
  };
}

// --------------------------------------------------------------- cymbidium

/// Cymbidium: ciuffo di lunghe foglie a nastro da pseudobulbi tondi e steli
/// eretti con grandi fiori cerosi.
class Cymbidium extends Specie {
  const Cymbidium();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.6, alto: 3.9, basso: -2.1);

  @override
  Vaso get vaso => const Vaso(colore: Vaso.antracite, lucido: true);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3F6B30),
    nuova: Color(0xFF65984A),
    retro: Color(0xFF6E8E58),
  );

  @override
  double get lucentezza => 0.4;

  static const _petalo = Color(0xFFF2C3BE);
  static const _labello = Color(0xFFF7EEDD);

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    const bulbi = 5;
    for (var b = 0; b < bulbi; b++) {
      final rnd = math.Random(b + 41);
      final angolo = b * 2 * math.pi / bulbi + rnd.nextDouble() * 0.5;
      final centro = V3.cilindro(angolo, 0.35 + 0.15 * rnd.nextDouble(), -0.06);
      // Pseudobulbo ovale alla base del ciuffo.
      c.fusto(
        [centro, centro + V3.su * 0.15, centro + V3.su * 0.3],
        spessore: 0.2,
        spessoreFinale: 0.1,
        colore: const Color(0xFF6E8F45),
        marcisce: true,
      );
      final foglie = (4 + 3 * v).round();
      for (var k = 0; k < foglie; k++) {
        final rk = math.Random(b * 20 + k);
        final seme = b * 20 + k;
        final a = angolo + (rk.nextDouble() - 0.5) * 2.2;
        final radiale = V3.cilindro(a, 1, 0);
        final eta = rk.nextDouble();
        final nuova = eta > 0.85 && v > 0.5;
        final l =
            (1.7 + 0.7 * rk.nextDouble()) *
            (0.8 + 0.25 * v) *
            (nuova ? 0.6 : 1);
        final base = centro + V3.su * 0.2;
        final piega = 0.25 + 0.3 * rk.nextDouble() + 0.6 * w;
        c.foglia(
          Foglia(
            base: base,
            controllo:
                base +
                V3.su * (l * (0.75 - 0.35 * w)) +
                radiale * (l * (0.12 + 0.2 * piega)),
            punta: c.fuoriDalVaso(
              base +
                  V3.su * (l * (0.7 - 0.9 * piega)) +
                  radiale * (l * (0.35 + 0.45 * piega)),
            ),
            larghezza: 0.032,
            forma: Forma.spada,
            eta: eta,
            seme: seme,
            nuova: nuova,
            lato: V3(-radiale.z, 0, radiale.x),
            rollio: (rk.nextDouble() - 0.5) * 0.8,
            coppa: 0.4,
          ),
        );
      }
    }

    // Steli fioriti eretti: con poca luce non fiorisce.
    final steli = v > 0.85
        ? 3
        : v > 0.55
        ? 2
        : v > 0.35
        ? 1
        : 0;
    for (var k = 0; k < steli; k++) {
      final angolo = k * 2.3 + 0.4;
      final radiale = V3.cilindro(angolo, 1, 0);
      final punti = _stelo(
        c,
        V3.cilindro(angolo, 0.3, 0.1),
        radiale,
        (2.7 + 0.3 * k) * (0.85 + 0.15 * v),
        (t) => 0.15 + 0.35 * t * t + 0.6 * w * t,
      );
      c.fusto(
        punti,
        spessore: 0.032,
        spessoreFinale: 0.022,
        colore: const Color(0xFF5F7F3E),
      );
      final fronte = (radiale + V3.su.cross(radiale) * (k.isEven ? 0.5 : -0.5))
          .normalizzato();
      const fiori = 7;
      for (var i = 0; i < fiori; i++) {
        final t = 0.45 + 0.52 * i / fiori;
        final attacco = _lungo(punti, t);
        final seme = 800 + k * 10 + i;
        final eta = 0.15 + 0.7 * i / fiori;
        final m = c.sintomi(seme, eta);
        final verso = i.isEven ? 1.0 : -1.0;
        final fuori = (fronte + V3.su.cross(fronte) * (0.6 * verso))
            .normalizzato();
        final centro = attacco + fuori * 0.14 - V3.su * 0.04;
        c.fusto(
          [attacco, centro],
          spessore: 0.014,
          colore: const Color(0xFF6E8E48),
        );
        final scala = 1 - 0.2 * i / fiori;
        fiore(
          c,
          centro: centro,
          fronte: fuori,
          alto: V3.su,
          seme: seme,
          sintomi: m,
          scala: scala,
          petali: [
            for (final a in const [0.0, 2.1, -2.1])
              Petalo(
                angolo: a,
                lunghezza: 0.26,
                larghezza: 0.28,
                colore: _petalo,
                forma: Forma.ellittica,
              ),
            for (final a in const [1.0, -1.0])
              Petalo(
                angolo: a,
                lunghezza: 0.25,
                larghezza: 0.26,
                colore: _petalo,
                forma: Forma.ellittica,
              ),
            const Petalo(
              angolo: math.pi,
              lunghezza: 0.16,
              larghezza: 0.5,
              colore: _labello,
              avanti: 0.5,
            ),
          ],
        );
        if (!m.cade) {
          // Labello punteggiato di rosso.
          puntino(
            c,
            centro - V3.su * (0.07 * scala) + fuori * 0.04,
            fuori,
            0.03 * scala,
            const Color(0xFFB3243C),
          );
        }
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Lunghe foglie a nastro verdi e arcuate, steli eretti con grandi fiori cerosi.',
      fare: 'Tanta luce, anche sole del mattino; tieni il terriccio leggermente umido in crescita.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Ciuffo folto, foglie nuove e tre steli pieni di fiori.',
      fare: 'Da maggio a settembre tienilo fuori a mezz\'ombra: le notti fresche di fine estate lo fanno fiorire.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie che ingialliscono dalla base e boccioli che cadono.',
      fare: 'Annaffia quando il substrato in superficie è asciutto e svuota sempre il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Pseudobulbi scuri e molli, foglie gialle che si piegano e si staccano.',
      fare: 'Sfila la pianta, togli radici e bulbi marci e rinvasa in terriccio per cymbidium ben drenato.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie mosce che si piegano, punte secche e fiori appassiti.',
      fare: 'Annaffia a fondo: il cymbidium non deve mai seccare del tutto, nemmeno d\'inverno.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Foglie scure, lunghe e molli e nessuno stelo fiorito.',
      fare: 'Gli serve molta luce: in casa vicino a una finestra a sud, d\'estate all\'aperto.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie giallastre con chiazze chiare e bruciate.',
      fare: 'Riparalo dal sole di mezzogiorno d\'estate; le foglie verde chiaro vanno bene, gialle no.',
    ),
    Scenario.freddo: (
      vedi: 'Boccioli che cadono e foglie spente dopo una gelata.',
      fare: 'Resiste fino a 5 °C, ma va portato dentro prima delle gelate e lontano dai termosifoni.',
    ),
  };
}
