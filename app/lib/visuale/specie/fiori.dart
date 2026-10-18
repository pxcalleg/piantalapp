import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';

/// Un petalo (o sepalo, o labello) di un fiore piatto.
class Petalo {
  const Petalo({
    required this.angolo,
    required this.lunghezza,
    required this.larghezza,
    required this.colore,
    this.forma = Forma.ovale,
    this.coppa = 0.2,
    this.avanti = 0,
  });

  /// Direzione nel piano del fiore: 0 = verso l'alto, poi in senso orario.
  final double angolo;
  final double lunghezza, larghezza;
  final Color colore;
  final Forma forma;
  final double coppa;

  /// Quanto il petalo si piega in avanti, verso chi guarda il fiore.
  final double avanti;
}

/// Disegna un fiore piatto: petali a raggiera attorno a [centro], sul piano
/// perpendicolare a [fronte]. [alto] dice dove sta il petalo superiore.
/// Se il fiore cade ([sintomi].cade) resta solo un petalo a terra.
void fiore(
  Costruttore c, {
  required V3 centro,
  required V3 fronte,
  required V3 alto,
  required List<Petalo> petali,
  required int seme,
  required Sintomi sintomi,
  double scala = 1,
}) {
  final f = fronte.normalizzato();
  final a = (alto - f * alto.dot(f)).normalizzato();
  final destra = f.cross(a).normalizzato();
  final m = Sintomi(
    gialla: sintomi.gialla,
    secca: sintomi.secca,
    marcia: sintomi.marcia,
    bruciata: sintomi.bruciata,
    variegatura: sintomi.variegatura,
  );
  if (sintomi.cade) {
    final p = petali.first;
    c.foglia(
      Foglia(
        base: centro,
        controllo: centro + a * (p.lunghezza * scala * 0.5),
        punta: centro + a * (p.lunghezza * scala),
        larghezza: p.larghezza,
        forma: p.forma,
        motivo: Motivo.nessuno,
        eta: 0.5,
        seme: seme,
        colore: p.colore,
        sintomi: Sintomi(cade: true, variegatura: sintomi.variegatura),
      ),
    );
    return;
  }
  // Fiori secchi: petali che si chiudono e si accartocciano.
  final chiude = 0.6 * sintomi.secca + 0.4 * sintomi.marcia;
  for (var i = 0; i < petali.length; i++) {
    final p = petali[i];
    final l = p.lunghezza * scala * (1 - 0.3 * chiude);
    final dir = a * math.cos(p.angolo) + destra * math.sin(p.angolo);
    final base = centro + f * (0.004 * i * scala);
    final avanti = p.avanti + 0.8 * chiude;
    c.foglia(
      Foglia(
        base: base,
        controllo: base + dir * (l * 0.5) + f * (l * 0.1 * avanti),
        punta: base + dir * (l * (1 - 0.3 * avanti)) + f * (l * 0.6 * avanti),
        larghezza: p.larghezza,
        forma: p.forma,
        motivo: Motivo.nessuno,
        eta: 0.5,
        seme: seme * 13 + i,
        lato: f.cross(dir),
        colore: p.colore,
        coppa: p.coppa,
        sintomi: m,
      ),
    );
  }
}

/// Bocciolo o piccolo dettaglio tondo, disegnato come un fusto corto.
void puntino(Costruttore c, V3 p, V3 dir, double raggio, Color colore) {
  c.fusto(
    [p, p + dir * (raggio * 0.5), p + dir * raggio],
    spessore: raggio * 1.6,
    spessoreFinale: raggio * 1.2,
    colore: colore,
  );
}
