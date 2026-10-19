import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

const _angoloAureo = 2.39996;

/// Ortensia: arbusto a cespo con grandi foglie opposte seghettate e, in cima
/// a ogni stelo, un grosso globo di fiorellini a quattro petali azzurri o
/// rosa. Quando ha sete foglie e fiori si afflosciano tutti insieme.
class Ortensia extends Specie {
  const Ortensia();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 2.5, alto: 3.1, basso: -2.3);

  @override
  Vaso get vaso => const Vaso(
    altezza: 1.55,
    raggioFondo: 0.75,
    colore: Color(0xFF5E7FA3),
    lucido: true,
  );

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF3D7A35),
    nuova: Color(0xFF7DB352),
    retro: Color(0xFF86A672),
  );

  @override
  double get lucentezza => 0.45;

  @override
  double get quotaATerra => 0.6;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;
    final steli = (6 + 3 * v).round();
    for (var k = 0; k < steli; k++) {
      final rnd = math.Random(k + 401);
      final angolo = k * _angoloAureo + rnd.nextDouble() * 0.4;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.1 + 0.2 * rnd.nextDouble(), -0.05);
      final h = (1.55 + 0.5 * rnd.nextDouble()) * (0.75 + 0.3 * v);
      final allarga = 0.5 + 0.4 * rnd.nextDouble();
      // Con la sete gli steli teneri si piegano verso l'esterno.
      final piega = 0.25 * w;
      V3 stelo(double t) => c.fuoriDalVaso(
        base +
            radiale * (allarga * h * t * 0.5 + piega * h * t * t) +
            V3.su * (h * t - piega * h * t * t * 0.9),
      );
      c.fusto(
        [for (var i = 0; i <= 8; i++) stelo(i / 8)],
        spessore: 0.05,
        spessoreFinale: 0.03,
        colore: const Color(0xFF5E7A3A),
        marcisce: true,
      );

      // Coppie di foglie opposte, ruotate di 90° a ogni nodo.
      const nodi = 4;
      for (var n = 0; n < nodi; n++) {
        final t = 0.3 + 0.62 * n / (nodi - 1);
        final p = stelo(t);
        final a = angolo + n * math.pi / 2 + 0.4;
        for (final segno in const [1.0, -1.0]) {
          final seme = k * 100 + n * 2 + (segno > 0 ? 0 : 1);
          final fuori = V3.cilindro(a, segno, 0);
          final eta = 1 - t;
          final nuova = n == nodi - 1 && v > 0.6;
          final l =
              (0.62 + 0.15 * v) *
              (0.85 + 0.3 * math.Random(seme).nextDouble()) *
              (nuova ? 0.7 : 1) *
              (1 - 0.15 * s.secchezza);
          final dir = (fuori * 0.9 + V3.su * (0.3 - 1.2 * w)).normalizzato();
          final attacco = p + dir * 0.06;
          c.foglia(
            Foglia(
              picciolo: p,
              base: attacco,
              controllo:
                  attacco + dir * (l * 0.5) + V3.su * (l * 0.12 * (1 - w)),
              punta: attacco + dir * l + V3.su * (-l * (0.25 + 0.55 * w)),
              larghezza: 0.46,
              forma: Forma.dentata,
              motivo: Motivo.robusta,
              eta: eta,
              seme: seme,
              nuova: nuova,
              coppa: 0.25 + 0.3 * s.secchezza,
              rollio: (math.Random(seme + 5).nextDouble() - 0.5) * 0.7,
            ),
          );
        }
      }

      // Con poca luce o troppo vigore perso non fiorisce.
      final fiorisce = v > 0.3 && k < steli - (v > 0.8 ? 0 : 1);
      final cima = stelo(1);
      final tangente = (cima - stelo(0.85)).normalizzato();
      if (fiorisce) {
        _infiorescenza(c, s, cima, tangente, k);
      } else {
        // Solo un ciuffo di foglioline nuove in punta.
        c.foglia(
          Foglia(
            base: cima,
            controllo: cima + tangente * 0.15,
            punta: cima + tangente * 0.3,
            larghezza: 0.3,
            forma: Forma.dentata,
            eta: 1,
            seme: k * 100 + 90,
            nuova: true,
          ),
        );
      }
    }
  }

  void _infiorescenza(
    Costruttore c,
    StatoPianta s,
    V3 cima,
    V3 tangente,
    int k,
  ) {
    final w = s.appassimento;
    final rnd = math.Random(k + 811);
    final raggio = (0.36 + 0.12 * rnd.nextDouble()) * (0.75 + 0.3 * s.vigore);
    // Il globo pesante si piega quando la pianta è assetata.
    final asse = (tangente + V3.su * (0.6 - 2.2 * w)).normalizzato();
    final centro = c.fuoriDalVaso(cima + asse * (raggio * 0.7));
    final m = c.sintomi(k + 811, 0.6);
    final sintomi = Sintomi(
      secca: (m.secca * 1.2 + 0.7 * s.bruciature).clamp(0.0, 1.0),
      marcia: m.marcia * 0.5,
      bruciata: m.bruciata,
    );
    // Azzurro nei terreni acidi, rosa in quelli calcarei: qui un cespo blu
    // con qualche globo che vira al lilla.
    final tinta = Color.lerp(
      const Color(0xFF6E8FD8),
      const Color(0xFFB58BD6),
      k.isEven ? 0.1 : 0.45,
    )!;
    const fiorellini = 34;
    for (var i = 0; i < fiorellini; i++) {
      // Punti distribuiti su una calotta sferica.
      final z = 1 - 1.55 * (i + 0.5) / fiorellini;
      final r = math.sqrt(math.max(0, 1 - z * z));
      final a = i * _angoloAureo;
      var e1 = asse.cross(V3.su);
      if (e1.lunghezza < 0.2) e1 = asse.cross(const V3(1, 0, 0));
      e1 = e1.normalizzato();
      final e2 = asse.cross(e1).normalizzato();
      final d = (asse * z + e1 * (r * math.cos(a)) + e2 * (r * math.sin(a)))
          .normalizzato();
      final punto = centro + d * raggio;
      var t1 = d.cross(V3.su);
      if (t1.lunghezza < 0.2) t1 = d.cross(const V3(1, 0, 0));
      t1 = t1.normalizzato();
      final t2 = d.cross(t1).normalizzato();
      final colore = Color.lerp(
        tinta,
        const Color(0xFFE3E9F7),
        0.15 + 0.35 * rnd.nextDouble(),
      )!;
      final l = raggio * (0.34 + 0.08 * rnd.nextDouble());
      final giro = rnd.nextDouble();
      for (var p = 0; p < 4; p++) {
        final b = p * math.pi / 2 + giro;
        final dir = t1 * math.cos(b) + t2 * math.sin(b);
        c.foglia(
          Foglia(
            base: punto,
            controllo: punto + dir * (l * 0.5) + d * (l * 0.08),
            punta: punto + dir * l - d * (l * 0.1),
            larghezza: 0.55,
            forma: Forma.petalo,
            motivo: Motivo.nessuno,
            eta: 0.6,
            seme: k * 1000 + i * 4 + p,
            lato: d.cross(dir),
            colore: colore,
            coppa: 0.15,
            sintomi: sintomi,
          ),
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Grandi foglie verdi seghettate e grossi globi di fiori azzurri in cima agli steli.',
      fare: 'Sole al mattino e ombra nelle ore calde; terriccio sempre leggermente umido, mai fradicio.',
    ),
    Scenario.rigogliosa: (
      vedi:
          'Cespo folto, foglie grandi e sode, un globo di fiori su ogni stelo.',
      fare: 'Concime per piante acidofile ogni 2-3 settimane da aprile a luglio; per avere fiori blu usa terriccio acido e acqua piovana.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie che ingialliscono e cadono dal basso, terriccio che resta fradicio.',
      fare: 'Ama l\'acqua ma non il ristagno: svuota il sottovaso e aspetta che la superficie del terriccio sia asciutta.',
    ),
    Scenario.marciume: (
      vedi: 'Steli anneriti alla base, foglie molli che cadono anche con il terriccio bagnato.',
      fare: 'Sfila la pianta, taglia le radici scure e rinvasa in terriccio per acidofile drenante, con argilla espansa sul fondo.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie e fiori afflosciati di colpo, globi piegati verso il basso, bordi delle foglie secchi.',
      fare: 'Annaffia subito a fondo: in poche ore si rialza. D\'estate in vaso controlla il terriccio ogni giorno.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Steli lunghi e deboli, foglie spente e pochi o nessun fiore.',
      fare: 'Spostala in un punto con qualche ora di sole al mattino: in ombra piena fiorisce poco.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie con chiazze chiare e bruciate, fiori che seccano e diventano marroni.',
      fare: 'Niente sole nelle ore centrali: mettila a est o in mezz\'ombra luminosa e annaffia la sera nei giorni caldi.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie spente che cadono e germogli anneriti dalle gelate.',
      fare: 'D\'inverno perde le foglie: è normale. Non potare i rami di un anno che porteranno i fiori e ripara il vaso dal gelo.',
    ),
  };
}
