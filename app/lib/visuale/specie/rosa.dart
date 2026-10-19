import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motore_3d.dart';
import '../stato_pianta.dart';

const _angoloAureo = 2.39996;

/// Rosa da giardino in vaso: steli spinosi, foglie composte da 5 foglioline
/// seghettate e fiori a petali sovrapposti. Le cinque schede (ibridi di tea,
/// floribunda, rampicante, inglese e miniatura) usano questa stessa classe
/// con portamento, fiori e colori diversi.
class Rosa extends Specie {
  const Rosa({
    required this.steli,
    required this.altezza,
    required this.apertura,
    required this.arco,
    required this.fioriPerStelo,
    required this.dimensioneFiore,
    required this.anelli,
    required this.petaloEsterno,
    required this.petaloInterno,
    required this.foglia,
    required this.inquadratura,
    required this.testiPropri,
    this.vaso = const Vaso(altezza: 1.6, raggioFondo: 0.72),
    this.spalliera = false,
    this.seme = 0,
  });

  /// Numero di steli principali che partono dal colletto.
  final int steli;

  /// Altezza degli steli in unità del vaso.
  final double altezza;

  /// Quanto gli steli si allargano verso l'esterno (0 = dritti).
  final double apertura;

  /// Quanto gli steli si piegano ad arco in cima (arbusti inglesi).
  final double arco;
  final int fioriPerStelo;
  final double dimensioneFiore;

  /// Giri di petali: pochi per i fiori a calice, tanti per le rose a coppa
  /// piena.
  final int anelli;
  final Color petaloEsterno, petaloInterno;

  /// Lunghezza di una fogliolina.
  final double foglia;

  /// Steli legati a un traliccio, come per le rampicanti.
  final bool spalliera;
  final int seme;

  @override
  final Inquadratura inquadratura;

  @override
  final Vaso vaso;

  /// Testi che cambiano rispetto a quelli comuni a tutte le rose.
  final Map<Scenario, TestoScenario> testiPropri;

  @override
  Map<Scenario, TestoScenario> get testi => {..._testiRosa, ...testiPropri};

  @override
  ColoriFoglia get colori => const ColoriFoglia(
    base: Color(0xFF2F5A2A),
    nuova: Color(0xFF7A5A34),
    retro: Color(0xFF6E8B5E),
  );

  @override
  double get lucentezza => 0.55;

  @override
  double get quotaATerra => 0.4;

  static const _legno = Color(0xFF8A6A48);

  @override
  void costruisci(Costruttore c, StatoPianta s) {
    final w = s.appassimento;
    final v = s.vigore;

    if (spalliera) _traliccio(c);

    for (var k = 0; k < steli; k++) {
      final rnd = math.Random(seme * 1000 + k + 3);
      final angolo = k * _angoloAureo + rnd.nextDouble() * 0.4;
      final radiale = V3.cilindro(angolo, 1, 0);
      final base = V3.cilindro(angolo, 0.08 + 0.12 * rnd.nextDouble(), -0.05);
      // Con poca luce gli steli si allungano ma restano esili.
      final h =
          altezza *
          (0.75 + 0.35 * rnd.nextDouble()) *
          (0.8 + 0.25 * v + 0.25 * (1 - v) * (s.spente > 0.4 ? 1 : 0));
      final allarga = apertura * (0.6 + 0.6 * rnd.nextDouble());
      final piega = arco * (0.7 + 0.5 * rnd.nextDouble()) + 0.5 * w;

      V3 stelo(double t) {
        final p = spalliera
            // Sul traliccio gli steli salgono a ventaglio sul piano x-y.
            ? V3(
                (k / math.max(1, steli - 1) - 0.5) * 1.6 * t * (0.6 + t),
                -0.05 + h * t,
                -0.25 + 0.15 * math.sin(k + t * 3),
              )
            : base +
                  radiale * (allarga * t * h * 0.5 + piega * h * t * t * 0.6) +
                  V3.su * (h * t - piega * h * t * t * 0.55);
        return c.fuoriDalVaso(p);
      }

      c.fusto(
        [for (var i = 0; i <= 10; i++) stelo(i / 10)],
        spessore: 0.045,
        spessoreFinale: 0.022,
        colore: Color(0xFF4F6B32),
        marcisce: true,
      );
      _spine(c, stelo, k);

      // Foglie composte lungo lo stelo.
      final nodi = (5 + 5 * v).round();
      for (var n = 0; n < nodi; n++) {
        final t = 0.18 + 0.74 * (n + 0.5) / nodi;
        final a = angolo + n * 2.2 + rnd.nextDouble() * 0.6;
        final lato = V3.cilindro(a, 1, 0);
        _fogliaComposta(
          c,
          s,
          stelo(t),
          (lato * 0.85 + V3.su * (0.35 - 0.9 * w)).normalizzato(),
          seme * 10000 + k * 100 + n,
          t,
          v > 0.55 && t > 0.75,
        );
      }

      // Fiori in cima (e lungo lo stelo nelle rampicanti): con poca luce o
      // con la pianta sofferente ne fa meno.
      final fiori = (fioriPerStelo * (v < 0.3 ? 0.0 : (0.4 + 0.7 * v)))
          .round()
          .clamp(0, fioriPerStelo + 2);
      for (final t in spalliera ? const [0.55, 0.78, 1.0] : const [1.0]) {
        final cima = stelo(t);
        var tangente = (cima - stelo(t - 0.1)).normalizzato();
        if (t < 1) {
          // Rami laterali che si staccano dal traliccio verso chi guarda.
          tangente = (tangente * 0.6 + const V3(0, 0.2, 1)).normalizzato();
        }
        final semeCima = (t * 10).round();
        if (fiori == 0) {
          _bocciolo(c, s, cima, tangente, seme * 50 + k * 3 + semeCima);
          continue;
        }
        for (var f = 0; f < fiori; f++) {
          final rf = math.Random(seme * 300 + k * 17 + f + semeCima * 7);
          var punto = cima;
          var asse = tangente;
          if (f > 0) {
            // Grappolo: corti peduncoli che si aprono attorno alla cima.
            final a = f * _angoloAureo + k + semeCima;
            final fuori = V3.cilindro(a, 1, 0);
            final lung = dimensioneFiore * (1.2 + 0.8 * rf.nextDouble());
            final fine = cima - tangente * (lung * 0.3) + fuori * lung;
            c.fusto(
              [cima - tangente * (lung * 0.4), fine],
              spessore: 0.018,
              colore: const Color(0xFF5A7438),
            );
            punto = fine;
            asse = (tangente * 0.7 + fuori * 0.6).normalizzato();
          }
          // I fiori assetati o al freddo si piegano.
          asse = (asse + V3.su * (-1.6 * w)).normalizzato();
          final sf = seme * 500 + k * 13 + f + semeCima * 101;
          if (f == fiori - 1 && f > 1) {
            _bocciolo(c, s, punto, asse, sf);
          } else {
            _fiore(c, s, punto, asse, sf);
          }
        }
      }
    }
  }

  void _traliccio(Costruttore c) {
    final alto = altezza * 1.05;
    for (var i = 0; i < 5; i++) {
      final x = (i - 2) * 0.42;
      c.fusto(
        [V3(x * 0.4, -0.06, -0.35), V3(x * 2.0, alto, -0.35)],
        spessore: 0.03,
        colore: _legno,
      );
    }
    for (var j = 1; j <= 4; j++) {
      final y = alto * j / 4.5;
      final larga = 0.35 + 0.85 * j / 4.5;
      c.fusto(
        [V3(-larga * 0.95, y, -0.35), V3(larga * 0.95, y, -0.35)],
        spessore: 0.022,
        colore: _legno,
      );
    }
  }

  void _spine(Costruttore c, V3 Function(double) stelo, int k) {
    final rnd = math.Random(seme * 77 + k);
    for (var i = 0; i < 6; i++) {
      final t = 0.1 + 0.8 * rnd.nextDouble();
      final p = stelo(t);
      final fuori = V3.cilindro(rnd.nextDouble() * 6.28, 1, 0);
      c.fusto(
        [p, p + fuori * 0.05 + V3.su * 0.02],
        spessore: 0.016,
        spessoreFinale: 0.003,
        colore: Color(0xFF8E4B36),
      );
    }
  }

  /// Picciolo con cinque foglioline: una in punta e due coppie opposte.
  void _fogliaComposta(
    Costruttore c,
    StatoPianta s,
    V3 attacco,
    V3 dir,
    int semeFoglia,
    double eta,
    bool nuova,
  ) {
    final w = s.appassimento;
    final l = foglia * (1 - 0.2 * s.secchezza) * (nuova ? 0.75 : 1);
    final rachide = l * 1.4;
    final fine = attacco + dir * rachide + V3.su * (-l * 0.3 * w);
    c.fusto(
      [attacco, attacco.medio(fine), fine],
      spessore: 0.012,
      colore: Color(0xFF4F6B32),
    );
    final lato = V3.su.cross(dir).normalizzato();
    final rnd = math.Random(semeFoglia);
    // Le foglioline di uno stesso picciolo si ammalano insieme.
    final m = c.sintomi(semeFoglia, eta);
    void fogliolina(V3 b, V3 d, double scala, int i) {
      final dd = (d + V3.su * (-0.5 * w - 0.1)).normalizzato();
      final ll = l * scala;
      c.foglia(
        Foglia(
          base: b,
          controllo: b + dd * (ll * 0.5) + V3.su * (ll * 0.05),
          punta: b + dd * ll + V3.su * (-ll * (0.1 + 0.35 * w)),
          larghezza: 0.32,
          forma: Forma.dentata,
          motivo: Motivo.centrale,
          eta: eta,
          seme: semeFoglia * 7 + i,
          nuova: nuova,
          coppa: 0.2 + 0.25 * s.secchezza,
          rollio: (rnd.nextDouble() - 0.5) * 0.8,
          sintomi: m,
        ),
      );
    }

    fogliolina(fine, dir, 1, 0);
    for (var j = 0; j < 2; j++) {
      final p = V3.bezier(attacco, attacco.medio(fine), fine, 0.45 + 0.3 * j);
      for (final segno in const [1.0, -1.0]) {
        fogliolina(
          p,
          (lato * segno + dir * 0.5).normalizzato(),
          0.75 + 0.12 * j,
          1 + j * 2 + (segno > 0 ? 0 : 1),
        );
      }
    }
  }

  Sintomi _sintomiFiore(Costruttore c, StatoPianta s, int semeFiore) {
    final m = c.sintomi(semeFiore, 0.7);
    return Sintomi(
      // I petali si seccano prima delle foglie quando manca l'acqua o il
      // sole scotta.
      secca: (m.secca * 1.2 + 0.35 * s.bruciature + 0.25 * s.appassimento)
          .clamp(0.0, 1.0),
      marcia: m.marcia * 0.6,
      bruciata: m.bruciata,
    );
  }

  void _fiore(Costruttore c, StatoPianta s, V3 centro, V3 asse, int sf) {
    final rnd = math.Random(sf);
    final m = _sintomiFiore(c, s, sf);
    // Ricettacolo e sepali verdi sotto la corolla.
    final sotto = centro - asse * (dimensioneFiore * 0.25);
    c.fusto(
      [centro - asse * (dimensioneFiore * 0.6), sotto],
      spessore: 0.03,
      colore: Color(0xFF55703A),
    );
    var e1 = asse.cross(V3.su);
    if (e1.lunghezza < 0.2) e1 = asse.cross(const V3(1, 0, 0));
    e1 = e1.normalizzato();
    final e2 = asse.cross(e1).normalizzato();
    final d = dimensioneFiore * (0.85 + 0.25 * s.vigore);
    for (var r = 0; r < anelli; r++) {
      final q = anelli == 1 ? 1.0 : r / (anelli - 1);
      final n = 5 + (r == 0 ? 0 : 1) + r;
      // Dentro i petali sono chiusi a cono, fuori si aprono e si piegano.
      final apre = (0.2 + 1.15 * q) * (1 + 0.25 * m.secca);
      final lung = d * (0.45 + 0.55 * q);
      final colore = Color.lerp(petaloInterno, petaloEsterno, q)!;
      for (var i = 0; i < n; i++) {
        final a = i * 2 * math.pi / n + r * 0.7 + rnd.nextDouble() * 0.3;
        final radiale = e1 * math.cos(a) + e2 * math.sin(a);
        final dir = asse * math.cos(apre) + radiale * math.sin(apre);
        final b = sotto + radiale * (d * 0.08 * q) + asse * (d * 0.12);
        c.foglia(
          Foglia(
            base: b,
            controllo: b + dir * (lung * 0.55) + asse * (lung * 0.1),
            punta:
                b +
                dir * lung +
                (radiale * math.cos(apre) - asse * math.sin(apre)) *
                    (lung * 0.25 * q),
            larghezza: 0.5 + 0.1 * q,
            forma: Forma.petalo,
            motivo: Motivo.nessuno,
            eta: 0.7,
            seme: sf * 31 + r * 11 + i,
            lato: asse.cross(radiale),
            colore: colore,
            coppa: 0.7 - 0.3 * q,
            sintomi: m,
          ),
        );
      }
    }
  }

  void _bocciolo(Costruttore c, StatoPianta s, V3 centro, V3 asse, int sf) {
    final m = _sintomiFiore(c, s, sf);
    final l = dimensioneFiore * 0.55;
    var e1 = asse.cross(V3.su);
    if (e1.lunghezza < 0.2) e1 = asse.cross(const V3(1, 0, 0));
    e1 = e1.normalizzato();
    final e2 = asse.cross(e1).normalizzato();
    for (var i = 0; i < 3; i++) {
      final a = i * 2.1;
      final radiale = e1 * math.cos(a) + e2 * math.sin(a);
      final dir = (asse + radiale * 0.18).normalizzato();
      c.foglia(
        Foglia(
          base: centro,
          controllo: centro + dir * (l * 0.5) + radiale * (l * 0.12),
          punta: centro + asse * l,
          larghezza: 0.35,
          forma: Forma.ovale,
          motivo: Motivo.nessuno,
          eta: 0.9,
          seme: sf * 13 + i,
          lato: asse.cross(radiale),
          colore: petaloInterno,
          coppa: 0.8,
          sintomi: m,
        ),
      );
    }
    // Sepali verdi attorno al bocciolo.
    for (var i = 0; i < 5; i++) {
      final a = i * 1.26 + 0.4;
      final radiale = e1 * math.cos(a) + e2 * math.sin(a);
      c.fusto(
        [centro, centro + asse * (l * 0.45) + radiale * (l * 0.25)],
        spessore: 0.014,
        spessoreFinale: 0.004,
        colore: Color(0xFF55703A),
      );
    }
  }
}

// -------------------------------------------------------------- varietà

const _inquadraturaCespuglio = Inquadratura(
  mezzaLarghezza: 2.3,
  alto: 3.6,
  basso: -2.3,
);

/// Testi comuni a tutte le rose; ogni gruppo cambia solo dove serve.
const Map<Scenario, TestoScenario> _testiRosa = {
  Scenario.sana: (
    vedi: 'Foglie verde scuro lucide, steli sodi e fiori pieni e profumati.',
    fare: 'Almeno 6 ore di sole al giorno; acqua a fondo quando i primi 3-4 cm di terriccio sono asciutti.',
  ),
  Scenario.rigogliosa: (
    vedi: 'Tanti getti nuovi rossicci, foglie fitte e una fioritura dopo l\'altra.',
    fare: 'Concime per rose ogni 2-3 settimane da marzo ad agosto e via i fiori appassiti, tagliando sopra una foglia a cinque foglioline.',
  ),
  Scenario.troppaAcqua: (
    vedi: 'Foglie che ingialliscono dal basso e cadono, terriccio sempre bagnato.',
    fare: 'Annaffia solo quando il terriccio è asciutto in superficie e controlla che il foro del vaso non sia otturato.',
  ),
  Scenario.marciume: (
    vedi: 'Steli che anneriscono dalla base, foglie gialle che cadono e boccioli che non si aprono.',
    fare: 'Sfila la pianta, taglia le radici scure e molli e rinvasa in terriccio nuovo con argilla espansa sul fondo.',
  ),
  Scenario.pocaAcqua: (
    vedi: 'Foglie e fiori mosci, petali che seccano sui bordi, terriccio asciutto e staccato dal vaso.',
    fare: 'Annaffia a fondo al mattino o alla sera, fino a far uscire l\'acqua dal foro; d\'estate in vaso può servire ogni giorno.',
  ),
  Scenario.pocaLuce: (
    vedi: 'Steli lunghi ed esili, poche foglie e nessun fiore, solo qualche bocciolo.',
    fare: 'Spostala nel punto più soleggiato: le rose fioriscono bene solo con almeno 6 ore di sole diretto.',
  ),
  Scenario.troppoSole: (
    vedi: 'Petali bruciati e secchi, foglie con chiazze chiare nei giorni più caldi.',
    fare: 'Nelle ondate di calore ombreggia il vaso nelle ore centrali, pacciama il terriccio e annaffia la sera.',
  ),
  Scenario.freddo: (
    vedi: 'Foglie spente che cadono, germogli mosci dopo una gelata.',
    fare: 'In vaso le radici gelano più facilmente: d\'inverno avvolgi il vaso con tessuto non tessuto e mettilo al riparo dal vento.',
  ),
};

/// Ibridi di tea: pochi steli dritti e un grande fiore a punta per stelo.
const rosaTeaIbrida = Rosa(
  steli: 5,
  altezza: 2.5,
  apertura: 0.4,
  arco: 0.05,
  fioriPerStelo: 1,
  dimensioneFiore: 0.42,
  anelli: 5,
  petaloEsterno: Color(0xFFC0182B),
  petaloInterno: Color(0xFF8E0E1E),
  foglia: 0.25,
  inquadratura: _inquadraturaCespuglio,
  seme: 1,
  testiPropri: {
    Scenario.sana: (
      vedi: 'Steli dritti e robusti, ognuno con un grande fiore rosso a punta e foglie lucide.',
      fare: 'Pieno sole e acqua a fondo quando i primi 3-4 cm di terriccio sono asciutti, senza bagnare le foglie.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Steli lunghi da recidere, un fiore grande in cima a ciascuno e getti nuovi rossicci.',
      fare: 'Concime per rose ogni 2-3 settimane da marzo ad agosto; taglia i fiori sfioriti sopra una foglia a cinque foglioline.',
    ),
  },
);

/// Floribunda: cespuglio più basso e fitto con mazzetti di fiori medi.
const rosaFloribunda = Rosa(
  steli: 7,
  altezza: 2.0,
  apertura: 0.6,
  arco: 0.12,
  fioriPerStelo: 4,
  dimensioneFiore: 0.27,
  anelli: 4,
  petaloEsterno: Color(0xFFF07A9A),
  petaloInterno: Color(0xFFD94A74),
  foglia: 0.22,
  inquadratura: _inquadraturaCespuglio,
  seme: 2,
  testiPropri: {
    Scenario.sana: (
      vedi: 'Cespuglio compatto coperto di mazzetti di fiori rosa e foglie verde scuro.',
      fare: 'Pieno sole e acqua a fondo quando i primi 3-4 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Mazzetti pieni di fiori e boccioli su ogni stelo, foglie fitte.',
      fare: 'Togli tutto il mazzetto quando è sfiorito e concima ogni 2-3 settimane fino ad agosto: rifiorisce fino all\'autunno.',
    ),
  },
);

/// Rampicante: steli lunghi legati a un traliccio, fiori a grappoli.
const rosaRampicante = Rosa(
  steli: 5,
  altezza: 3.2,
  apertura: 0.2,
  arco: 0,
  fioriPerStelo: 3,
  dimensioneFiore: 0.28,
  anelli: 4,
  petaloEsterno: Color(0xFFF7B8C4),
  petaloInterno: Color(0xFFE98AA0),
  foglia: 0.22,
  spalliera: true,
  vaso: Vaso(altezza: 1.7, raggioFondo: 0.75),
  inquadratura: Inquadratura(mezzaLarghezza: 2.5, alto: 4.5, basso: -2.4),
  seme: 3,
  testiPropri: {
    Scenario.sana: (
      vedi: 'Lunghi steli legati al traliccio, foglie lucide e grappoli di fiori rosa chiaro.',
      fare: 'Vaso grande (almeno 40-50 litri), pieno sole e acqua a fondo quando il terriccio è asciutto in superficie.',
    ),
    Scenario.rigogliosa: (
      vedi:
          'Steli che si coprono di grappoli di fiori lungo tutto il traliccio.',
      fare: 'Lega gli steli il più possibile in orizzontale o a ventaglio: così fioriscono lungo tutto lo stelo. Concima fino ad agosto.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Steli lunghi e spogli che cercano la luce, quasi nessun fiore.',
      fare: 'Mettila contro un muro esposto a sud o a ovest: senza sole diretto fa solo foglie.',
    ),
  },
);

/// Arbustiva o inglese: steli ad arco e fiori a coppa pieni di petali.
const rosaInglese = Rosa(
  steli: 8,
  altezza: 2.4,
  apertura: 0.7,
  arco: 0.45,
  fioriPerStelo: 2,
  dimensioneFiore: 0.25,
  anelli: 7,
  petaloEsterno: Color(0xFFF8BE86),
  petaloInterno: Color(0xFFE9824A),
  foglia: 0.27,
  inquadratura: Inquadratura(mezzaLarghezza: 2.6, alto: 3.4, basso: -2.3),
  seme: 4,
  testiPropri: {
    Scenario.sana: (
      vedi: 'Arbusto rotondo con steli ad arco e fiori a coppa color albicocca, pieni di petali.',
      fare: 'Sole per almeno 6 ore, anche solo al mattino; acqua a fondo quando i primi 3-4 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Arbusto pieno, coperto di fiori a coppa profumati e di boccioli.',
      fare: 'Concima ogni 2-3 settimane fino ad agosto e togli i fiori sfioriti: rifiorisce in più ondate.',
    ),
  },
);

/// Miniatura: piantina bassa e fitta con tanti fiorellini.
const rosaMiniatura = Rosa(
  steli: 9,
  altezza: 1.5,
  apertura: 0.7,
  arco: 0.1,
  fioriPerStelo: 3,
  dimensioneFiore: 0.17,
  anelli: 4,
  petaloEsterno: Color(0xFFFFE27A),
  petaloInterno: Color(0xFFF4B731),
  foglia: 0.13,
  vaso: Vaso(
    altezza: 1.3,
    raggioFondo: 0.76,
    colore: Vaso.ceramicaChiara,
    lucido: true,
  ),
  inquadratura: Inquadratura(mezzaLarghezza: 1.9, alto: 2.3, basso: -1.8),
  seme: 5,
  testiPropri: {
    Scenario.sana: (
      vedi:
          'Piantina fitta con foglioline lucide e tanti piccoli fiori gialli.',
      fare: 'Sole diretto, meglio all\'aperto; acqua quando i primi 2 cm di terriccio sono asciutti.',
    ),
    Scenario.rigogliosa: (
      vedi: 'Cuscino di foglioline coperto di fiorellini e boccioli.',
      fare: 'Concime per piante da fiore ogni 2 settimane in primavera e in estate e via i fiori secchi.',
    ),
    Scenario.pocaAcqua: (
      vedi: 'Foglioline mosce e fiori che seccano: il vasetto piccolo si asciuga in fretta.',
      fare: 'Annaffia a fondo; d\'estate controlla il terriccio ogni giorno e, se serve, passala in un vaso un po\' più grande.',
    ),
    Scenario.pocaLuce: (
      vedi: 'Steli sottili e allungati, foglie che cadono, nessun fiore.',
      fare: 'In casa non dura: portala all\'aperto al sole o sul davanzale più luminoso, a sud.',
    ),
    Scenario.freddo: (
      vedi: 'Foglioline spente che cadono e germogli mosci.',
      fare: 'È rustica, ma in un vasetto piccolo le radici gelano: d\'inverno riparala vicino a un muro o in un luogo fresco e luminoso.',
    ),
  },
);
