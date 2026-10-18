import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';
import 'aloe.dart';
import 'grasse_comune.dart';

/// Haworthiopsis attenuata: piccola rosetta fitta di foglie appuntite verde
/// scuro con fasce di tubercoli bianchi.
class Haworthia extends Specie {
  const Haworthia();

  @override
  Inquadratura get inquadratura =>
      const Inquadratura(mezzaLarghezza: 1.7, alto: 2.0, basso: -1.6);

  @override
  Vaso get vaso => vasoGrasse;

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2C4A2F),
    nuova: Color(0xFF3F6640),
    retro: Color(0xFF34553A),
  );

  @override
  double get lucentezza => 0.35;

  @override
  bool get foglieCadono => false;

  @override
  bool get marciumeAMacchie => true;

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    rosettaAffusolata(
      c,
      s,
      centro: const V3(0, 0, 0),
      foglie: (20 + 10 * s.vigore).round(),
      lunghezza: 0.95,
      larghezza: 0.17,
      elevBase: 0.75,
      elevCima: 1.4,
      motivo: Motivo.haworthia,
      semeBase: 41,
      incurva: 0.05,
    );
    if (s.vigore > 0.85) {
      for (var i = 0; i < 3; i++) {
        rosettaAffusolata(
          c,
          s,
          centro: V3.cilindro(0.4 + i * 2.1, 0.68, 0),
          foglie: 9,
          lunghezza: 0.42,
          larghezza: 0.18,
          elevBase: 0.8,
          elevCima: 1.4,
          motivo: Motivo.haworthia,
          semeBase: 400 + i * 20,
          incurva: 0.05,
        );
      }
    }
  }

  @override
  Map<Scenario, TestoScenario> get testi => const {
    Scenario.sana: (
      vedi: 'Rosetta fitta di foglie appuntite verde scuro, sode, con le fasce di puntini bianchi in rilievo.',
      fare: 'Luce intensa ma filtrata, niente sole pieno d\'estate; acqua quando il terriccio è asciutto.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Tante rosette figlie attorno alla pianta madre, che formano un cespo.',
      fare: 'Quando il vaso è pieno dividi il cespo in primavera e rinvasa le rosette in vasetti bassi.',
    ),
    Scenario.troppaAcqua: (
      vedi: 'Foglie gonfie, molli e traslucide, che ingialliscono alla base.',
      fare: 'Lascia asciugare del tutto il terriccio e usa un substrato con molta pomice o sabbia.',
    ),
    Scenario.marciume: (
      vedi: 'Foglie che si afflosciano e si staccano, base scura e marcia.',
      fare: 'Estrai la pianta, salva le rosette con base sana, lasciale asciugare e ripiantale in terriccio asciutto.',
    ),
    Scenario.pocaAcqua: (
      vedi:
          'Foglie sottili e raggrinzite che si chiudono, punte secche e brune.',
      fare: 'Annaffia a fondo e lascia scolare; le foglie tornano piene in pochi giorni.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Rosetta che si apre e si allunga, foglie più lunghe, piatte e sbiadite.',
      fare: 'Avvicinala a una finestra luminosa; tollera bene la mezz\'ombra, ma non il buio.',
    ),
    Scenario.troppoSole: (
      vedi: 'Foglie che diventano rosso-arancio o brune, con punte secche.',
      fare: 'Spostala in luce filtrata: col tempo torna verde scuro.',
    ),
    Scenario.freddo: (
      vedi: 'Foglie molli e traslucide che si piegano dopo il freddo.',
      fare: 'Tienila sopra i 5-10 °C e quasi asciutta d\'inverno.',
    ),
  };
}
