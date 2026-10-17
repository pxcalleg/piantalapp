import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

/// Sansevieria: rosetta di foglie erette e rigide che nascono dal
/// terriccio, con fasce chiare e bordo giallo.
class Sansevieria extends Specie {
  const Sansevieria();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.9, alto: 4.1, basso: -2.1);

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2D4C30),
    nuova: Color(0xFF3F6A3B),
    retro: Color(0xFF4F6E4A),
  );

  @override
  double get lucentezza => 0.45;

  // Le foglie non cadono: con marciume e freddo si piegano dalla base.
  @override
  bool get foglieCadono => false;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final v = s.vigore;
    final n = (8 + 6 * v).round();
    for (var k = 0; k < n; k++) {
      final rnd = math.Random(k + 5);
      final angolo = k * 2.39996 + rnd.nextDouble() * 0.4;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.06 + 0.32 * rnd.nextDouble(), -0.06);
      final eta = rnd.nextDouble();
      final m = c.sintomi(k + 5, eta);
      // Quanto la foglia è molle e si piega fino a cadere di lato.
      final piega =
          (m.marcia * 1.1 + (m.cade ? 0.75 : 0) + 0.15 * s.appassimento).clamp(
            0.0,
            1.0,
          );
      final nuova = k == n - 1 && v > 0.6;
      final altezza =
          (2.2 + 1.3 * rnd.nextDouble()) *
          (0.7 + 0.35 * v) *
          (nuova ? 0.55 : 1);
      final apertura = 0.1 + 0.12 * rnd.nextDouble() + 1.1 * piega;
      final punta =
          base +
          V3.su * (altezza * (1 - 0.8 * piega)) +
          radiale * (altezza * apertura * 0.6);
      final controllo =
          base +
          V3.su * (altezza * (0.55 - 0.35 * piega)) +
          radiale * (altezza * apertura * 0.15);
      // La lamina guarda in direzioni diverse attorno alla rosetta.
      final giro = (rnd.nextDouble() - 0.5) * 1.6;
      final tangente = V3(-radiale.z, 0, radiale.x);
      c.foglia(
        Foglia(
          base: base,
          controllo: controllo,
          punta: c.fuoriDalVaso(punta),
          larghezza: 0.09,
          forma: Forma.spada,
          motivo: Motivo.sansevieria,
          eta: eta,
          seme: k + 5,
          nuova: nuova,
          lato: tangente * math.cos(giro) + radiale * math.sin(giro),
          coppa: 0.35,
          sintomi: Sintomi(
            gialla: m.gialla,
            secca: m.secca * 0.7 + 0.3 * s.appassimento,
            marcia: m.marcia,
            bruciata: m.bruciata,
            variegatura: m.variegatura,
          ),
        ),
      );
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Foglie erette, rigide e sode, con le fasce chiare e il bordo giallo ben netti.',
      fare: 'Va bene quasi ogni luce; acqua solo quando il terriccio è asciutto anche in profondità.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Foglie nuove che spuntano dalla base, la rosetta si allarga.',
      fare: 'Luce intensa e concime per piante grasse a metà dose ogni 1-2 mesi, da aprile a settembre.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie che ingialliscono e si ammorbidiscono, terriccio sempre umido.',
      fare: 'Smetti di annaffiare finché il terriccio è asciutto fino in fondo; d\'inverno basta ogni 30-45 giorni.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie molli che si piegano di lato, base scura e marcia, cattivo odore.',
      fare: 'Togli la pianta dal vaso, elimina le parti marce, lascia asciugare un giorno e rinvasa in terriccio per piante grasse.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglie raggrinzite e più sottili, punte secche, terriccio staccato dal vaso.',
      fare: 'Annaffia a fondo una volta: in pochi giorni le foglie tornano sode. Non serve di più.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Poche foglie nuove, colori meno vivaci, crescita quasi ferma.',
      fare: 'Sopravvive anche così, ma vicino a una finestra cresce e mantiene i colori.',
    ),
    Scenario.troppoSole: (
      vedi: 'Chiazze chiare e secche sulle foglie dopo un passaggio brusco al sole pieno.',
      fare: 'Il sole pieno lo sopporta, ma va abituata un po\' alla volta.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie molli che si piegano e perdono colore dopo il freddo.',
      fare: 'Tienila sopra i 10 °C e all\'asciutto d\'inverno; taglia alla base le foglie danneggiate.',
    ),
  };
}
