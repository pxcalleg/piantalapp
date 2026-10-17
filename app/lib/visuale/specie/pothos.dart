import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

/// Pothos: fusti ricadenti oltre il bordo del vaso e qualche fusto eretto,
/// foglie a cuore con striature dorate.
class Pothos extends Specie {
  const Pothos();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.3, alto: 2.08, basso: -2.82);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3F8A34),
    nuova: Color(0xFF7DBE4E),
    retro: Color(0xFF8DB36A),
  );

  @override
  double get lucentezza => 0.7;

  static final _fusti = _generaFusti();

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final vigore = s.vigore;
    for (final f in _fusti) {
      // Poca vigoria = fusti lunghi e spogli (pianta filata).
      final lunghezza = f.lunghezza * (0.85 + 0.35 * (1 - vigore));
      final altezza = f.altezza * (1 - 0.55 * w);
      final caduta = f.ricadente ? f.ricaduta * (1 + 0.6 * w) : 0.15 * w;

      V3 punto(double t) {
        final r = f.r0 + lunghezza * t;
        final y =
            altezza * math.sin(math.pi * math.min(t * 1.15, 1)) -
            caduta * t * t;
        return c.fuoriDalVaso(V3.cilindro(f.angolo + f.torsione * t, r, y));
      }

      const passi = 18;
      c.fusto(
        [for (var i = 0; i <= passi; i++) punto(i / passi)],
        spessore: 0.035 * (0.7 + 0.3 * vigore),
        colore: const Color(0xFF6E8F3E),
        marcisce: true,
      );

      final numeroFoglie = (f.foglie * (0.45 + 0.75 * vigore)).round();
      for (var k = 0; k < numeroFoglie; k++) {
        final rnd = math.Random(f.seme * 100 + k);
        final t = 0.1 + (k + 0.5) / numeroFoglie * 0.9;
        final base = punto(t);
        final tangente = (punto(math.min(t + 0.03, 1)) - base).normalizzato();
        final radiale = base.orizzontale();
        final lato = V3(-radiale.z, 0, radiale.x) * (k.isEven ? 1.0 : -1.0);
        final su = 0.55 - 1.5 * w + (rnd.nextDouble() - 0.5) * 0.3;
        final dir =
            (radiale * 0.5 +
                    lato * (0.55 + rnd.nextDouble() * 0.3) +
                    V3.su * su +
                    tangente * 0.25)
                .normalizzato();
        final nuova = t > 0.86 && vigore > 0.55;
        final dimensione =
            (0.24 + 0.24 * vigore) *
            (0.75 + 0.5 * rnd.nextDouble()) *
            (nuova ? 0.7 : 1) *
            (1 - 0.25 * s.secchezza);
        final attacco = base + dir * 0.1;
        c.foglia(
          Foglia(
            picciolo: base,
            base: attacco,
            controllo:
                attacco +
                dir * (dimensione * 0.5) +
                V3.su * (-dimensione * (0.05 + 0.2 * w)),
            punta: attacco + dir * dimensione,
            larghezza: 0.56,
            forma: Forma.cuore,
            motivo: Motivo.pothos,
            eta: t,
            seme: f.seme * 100 + k,
            nuova: nuova,
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie sode, verdi e lucide, con la variegatura ben visibile.',
      fare: 'Luce indiretta, acqua quando metà terriccio è asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Tante foglie grandi e nuove punte verde chiaro: la pianta sta crescendo.',
      fare: 'Continua così; in primavera e estate concima una volta al mese.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gialle a partire dal basso, terriccio sempre bagnato.',
      fare: 'Sospendi le annaffiature finché metà terriccio è asciutto e svuota il sottovaso.',
    ),
    Scenario.marciume: (
      vedi: 'Fusti scuri e molli vicino al terriccio, foglie che anneriscono, odore di stantio.',
      fare: 'Togli la pianta dal vaso, taglia le radici marce e rinvasa in terriccio asciutto; salva qualche talea sana.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie flosce e cadenti, bordi secchi, terriccio chiaro e staccato dal vaso.',
      fare: 'Annaffia a fondo, anche per immersione: in poche ore le foglie si rialzano.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Fusti lunghi con poche foglie piccole, la variegatura sparisce.',
      fare: 'Avvicinala a una finestra luminosa, senza sole diretto, e accorcia i fusti spogli.',
    ),
    Scenario.troppoSole: (
      vedi: 'Macchie chiare e secche sulle foglie più esposte.',
      fare: 'Spostala lontano dal sole diretto; le foglie bruciate non tornano verdi, si possono togliere.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie che cadono all\'improvviso, colori spenti.',
      fare: 'Tienila sopra i 15 °C, lontano da finestre aperte d\'inverno e da spifferi.',
    ),
  };
}

class _Fusto {
  const _Fusto({
    required this.seme,
    required this.angolo,
    required this.r0,
    required this.lunghezza,
    required this.altezza,
    required this.ricadente,
    required this.ricaduta,
    required this.torsione,
    required this.foglie,
  });

  final int seme;
  final double angolo, r0, lunghezza, altezza, ricaduta, torsione;
  final bool ricadente;
  final int foglie;
}

List<_Fusto> _generaFusti() {
  final rnd = math.Random(42);
  const n = 8;
  return [
    for (var i = 0; i < n; i++)
      () {
        final ricadente = i % 3 != 0;
        return _Fusto(
          seme: i + 1,
          angolo: i * 2 * math.pi / n + rnd.nextDouble() * 0.5,
          r0: 0.1 + rnd.nextDouble() * 0.45,
          lunghezza: ricadente
              ? 1.0 + rnd.nextDouble() * 0.6
              : 0.35 + rnd.nextDouble() * 0.3,
          altezza: ricadente
              ? 0.35 + rnd.nextDouble() * 0.35
              : 0.75 + rnd.nextDouble() * 0.45,
          ricadente: ricadente,
          ricaduta: 0.8 + rnd.nextDouble() * 0.9,
          torsione: (rnd.nextDouble() - 0.5) * 0.8,
          foglie: ricadente ? 9 : 5,
        );
      }(),
  ];
}
