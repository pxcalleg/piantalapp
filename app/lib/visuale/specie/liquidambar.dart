import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

const _angoloAureo = 2.39996;

/// Liquidambar: giovane albero da esterno in un grande vaso, con tronco
/// dritto, chioma a piramide e foglie a stella con 5 lobi su lunghi
/// piccioli. Con il freddo d'autunno le foglie diventano rosse, arancio e
/// viola prima di cadere.
class Liquidambar extends Specie {
  const Liquidambar();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.4, alto: 5.9, basso: -2.6);

  @override
  Vaso get vaso => const Vaso(altezza: 1.6, raggioFondo: 0.7);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3C7A2B),
    nuova: Color(0xFF8DC05E),
    retro: Color(0xFFA9BE93),
  );

  @override
  double get lucentezza => 0.6;

  @override
  bool get marciumeAMacchie => true;

  // Le foglie cadute le disegna la specie, intere e a stella.
  @override
  bool get foglieCadono => false;

  static const _autunno = [
    Color(0xFFB3262A),
    Color(0xFFD2601F),
    Color(0xFF6B1F3D),
    Color(0xFFDDA02C),
    Color(0xFFC03A22),
  ];

  /// Lobi della stella: angolo dalla nervatura centrale e lunghezza.
  static const _lobi = [
    (0.0, 1.0),
    (0.85, 0.92),
    (-0.85, 0.92),
    (1.65, 0.68),
    (-1.65, 0.68),
  ];

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    // Colori d'autunno: foglie che cadono senza ingiallire per malattia.
    final autunno = ((s.caduta - s.ingiallimento - 0.1) / 0.15).clamp(0.0, 1.0);

    final altezza = 3.9 + 0.5 * v;
    V3 tronco(double t) =>
        V3(0.04 * math.sin(t * 4), -0.07 + altezza * t, 0.03 * math.cos(t * 5));
    c.fusto(
      [for (var i = 0; i <= 12; i++) tronco(i / 12)],
      spessore: 0.15,
      spessoreFinale: 0.03,
      colore: const Color(0xFF7D7064),
    );

    void foglia(V3 attacco, V3 verso, double eta, int seme, bool nuova) {
      final rf = math.Random(seme);
      final m = c.sintomi(seme, eta);
      final lunghezza =
          0.62 *
          (0.75 + 0.35 * v) *
          (0.85 + 0.3 * rf.nextDouble()) *
          (nuova ? 0.7 : 1) *
          (1 - 0.2 * s.secchezza);
      Color? colore;
      if (autunno > 0) {
        final tinta = _autunno[rf.nextInt(_autunno.length)];
        final verde = nuova ? colori.nuova : colori.base;
        final misto = Color.lerp(
          verde,
          tinta,
          autunno * (0.7 + 0.3 * rf.nextDouble()),
        )!;
        // Il motore illumina di più le foglie colorate: compensa.
        colore = Color.lerp(Colors.black, misto, 0.75);
      }

      if (m.cade) {
        if (rf.nextDouble() > 0.6) return;
        final a = math.atan2(attacco.z, attacco.x) + (rf.nextDouble() - 0.5);
        final r = 1.1 + rf.nextDouble() * 0.5;
        final centro = V3(
          r * math.cos(a),
          -c.altezzaVaso + 0.01,
          r * math.sin(a),
        );
        final dirA = rf.nextDouble() * math.pi * 2;
        _stella(
          c,
          centro: centro,
          dir: V3(math.cos(dirA), 0, math.sin(dirA)),
          lunghezza: lunghezza,
          rollio: 0,
          eta: eta,
          seme: seme,
          nuova: false,
          colore: colore,
          sintomi: Sintomi(
            gialla: 0.35 * (1 - autunno),
            secca: 0.3 + 0.4 * rf.nextDouble(),
            marcia: s.marciume * 0.6,
            variegatura: m.variegatura,
          ),
        );
        return;
      }

      // Picciolo lungo che porta la lamina in fuori e in su; con la sete la
      // foglia pende.
      final dirPicciolo = (verso + V3.su * (0.45 - 1.3 * w)).normalizzato();
      final centro = attacco + dirPicciolo * (lunghezza * 0.6);
      final dir = (verso + V3.su * (-0.05 - 1.1 * w - 0.2 * rf.nextDouble()))
          .normalizzato();
      _stella(
        c,
        picciolo: attacco,
        centro: centro,
        dir: dir,
        lunghezza: lunghezza,
        rollio: (rf.nextDouble() - 0.5) * 0.9,
        eta: eta,
        seme: seme,
        nuova: nuova,
        colore: colore,
        sintomi: m,
      );
    }

    // Rami a piramide: lunghi in basso, corti in cima.
    final rami = (7 + 4 * v).round();
    for (var r = 0; r < rami; r++) {
      final rnd = math.Random(r + 401);
      final q = r / math.max(1, rami - 1);
      final angolo = r * _angoloAureo + rnd.nextDouble() * 0.3;
      final attacco = tronco(0.25 + 0.65 * q);
      final radiale = V3.cilindro(angolo, 1, 0);
      final lunghezza =
          (2.0 - 1.3 * q) * (0.85 + 0.25 * rnd.nextDouble()) * (0.8 + 0.2 * v);
      final sale = lunghezza * (0.4 + 0.25 * rnd.nextDouble()) * (1 - 0.3 * w);
      final ricade = lunghezza * (0.25 + 0.4 * w);
      V3 ramo(double t) =>
          attacco +
          radiale * (lunghezza * t) +
          V3.su * (sale * t - ricade * t * t);
      c.fusto(
        [for (var i = 0; i <= 6; i++) ramo(i / 6)],
        spessore: 0.05,
        spessoreFinale: 0.014,
        colore: const Color(0xFF7A6B5C),
      );

      final n = (2 + 5 * v + 2 * (1 - q)).round();
      for (var k = 0; k < n; k++) {
        final t = 0.3 + 0.7 * (k + 0.5) / n;
        final punto = ramo(t);
        final tangente = (ramo(math.min(1, t + 0.05)) - punto).normalizzato();
        final lato =
            V3.su.cross(tangente).normalizzato() * (k.isEven ? 1.0 : -1.0);
        final verso = (tangente * 0.55 + lato * 0.8).normalizzato();
        foglia(
          punto,
          verso,
          0.5 * q + 0.5 * t,
          r * 40 + k + 7,
          t > 0.85 && v > 0.55,
        );
      }
      // Ciuffo in punta al ramo.
      foglia(
        ramo(1),
        (ramo(1) - ramo(0.9)).orizzontale(),
        1,
        r * 40 + 39,
        v > 0.55,
      );
    }

    // Foglie sulla cima del tronco.
    final cima = (3 + 3 * v).round();
    for (var k = 0; k < cima; k++) {
      final t = 0.9 + 0.1 * k / math.max(1, cima - 1);
      final verso = V3.cilindro(k * _angoloAureo + 1.1, 1, 0);
      foglia(tronco(t), verso, t, 900 + k, v > 0.55);
    }
  }

  /// Foglia a stella: cinque lobi lanceolati sullo stesso piano, con gli
  /// stessi sintomi e lo stesso colore.
  void _stella(
    Costruttore c, {
    V3? picciolo,
    required V3 centro,
    required V3 dir,
    required double lunghezza,
    required double rollio,
    required double eta,
    required int seme,
    required bool nuova,
    required Color? colore,
    required Sintomi sintomi,
  }) {
    var lato = V3.su.cross(dir);
    if (lato.lunghezza < 0.15) lato = const V3(1, 0, 0).cross(dir);
    lato = lato.normalizzato();
    lato = lato * math.cos(rollio) + dir.cross(lato) * math.sin(rollio);
    var normale = lato.cross(dir).normalizzato();
    if (normale.y < 0) normale = -normale;

    for (var i = 0; i < _lobi.length; i++) {
      final (angolo, quota) = _lobi[i];
      final d = dir * math.cos(angolo) + lato * math.sin(angolo);
      final l = lunghezza * quota;
      final punta = centro + d * l - normale * (l * 0.08);
      c.foglia(
        Foglia(
          picciolo: i == 0 ? picciolo : null,
          base: centro,
          controllo: centro + d * (l * 0.5) + normale * (l * 0.04),
          punta: punta,
          larghezza: 0.36,
          forma: Forma.lanceolata,
          lato: normale.cross(d),
          eta: eta,
          seme: seme,
          nuova: nuova,
          colore: colore,
          coppa: 0.08,
          sintomi: sintomi,
        ),
      );
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Giovane albero dritto con la chioma a piramide e foglie a stella con 5 lobi, verde brillante e lucide.',
      fare: 'Sole pieno o mezz\'ombra, terreno fresco e acido; in vaso annaffia quando i primi centimetri di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi:
          'Chioma piena, rami lunghi e foglie nuove verde chiaro sulle punte.',
      fare: 'Continua così: in primavera dai un concime a lenta cessione per piante acidofile e, quando il vaso è stretto, mettilo in piena terra.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie che ingialliscono tra le nervature e terriccio sempre fradicio nel vaso.',
      fare: 'In natura ama i terreni umidi, ma in vaso l\'acqua non deve ristagnare: svuota il sottovaso e controlla che i fori non siano chiusi.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie gialle e scure che cadono, rami che si svuotano, terriccio bagnato che sa di stantio.',
      fare: 'Togli la zolla, taglia le radici nere e molli e rinvasa in terriccio nuovo e drenante, in un vaso con buoni fori.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie che pendono dai piccioli, bordi secchi e arricciati, terriccio staccato dal vaso.',
      fare: 'Annaffia a fondo finché l\'acqua esce dai fori; d\'estate in vaso può servire acqua ogni 2-3 giorni. Una pacciamatura aiuta.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Chioma rada, poche foglie piccole e opache; in autunno i colori restano spenti.',
      fare: 'Spostalo in pieno sole o almeno con sole per metà giornata: è con il sole che fa i rossi più belli.',
    ),
    Scenario.troppoSole: (
      vedi: 'Bordi delle foglie bruciati e secchi dopo giorni di caldo torrido, soprattutto in vaso su un terrazzo assolato.',
      fare: 'Ama il sole, ma in vaso le radici si scaldano: d\'estate annaffia più spesso, ombreggia il vaso e pacciama il terriccio.',
    ),
    Scenario.freddo: (
      vedi: 'Con le prime notti fredde le foglie diventano rosse, arancio e viola e poi cadono: in autunno è normale. In primavera una gelata tardiva può annerire le foglie appena nate.',
      fare: 'In autunno non fare nulla e raccogli le foglie. Se in primavera è prevista una gelata, copri la chioma con tessuto non tessuto; in vaso proteggi le radici dal gelo forte.',
    ),
  };
}
