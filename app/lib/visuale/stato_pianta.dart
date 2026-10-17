import 'dart:ui' show lerpDouble;

/// Condizioni della pianta simulata. Ogni valore va da 0 (assente) a 1
/// (massimo).
class StatoPianta {
  const StatoPianta({
    this.vigore = 0.7,
    this.ingiallimento = 0,
    this.secchezza = 0,
    this.marciume = 0,
    this.spente = 0,
    this.appassimento = 0,
    this.caduta = 0,
    this.bruciature = 0,
    this.umiditaTerreno = 0.5,
  });

  /// Quante foglie ha e quanto sono grandi; basso = pianta filata.
  final double vigore;
  final double ingiallimento;

  /// Foglie secche e accartocciate, bordi marroni.
  final double secchezza;

  /// Foglie scure e molli alla base, fusti anneriti.
  final double marciume;

  /// Colori spenti e opachi.
  final double spente;

  /// Foglie e fusti cadenti, mosci.
  final double appassimento;

  /// Quota di foglie già cadute a terra.
  final double caduta;

  /// Macchie chiare da sole diretto.
  final double bruciature;

  /// 0 = terriccio asciutto e screpolato, 1 = fradicio.
  final double umiditaTerreno;

  StatoPianta copyWith({
    double? vigore,
    double? ingiallimento,
    double? secchezza,
    double? marciume,
    double? spente,
    double? appassimento,
    double? caduta,
    double? bruciature,
    double? umiditaTerreno,
  }) => StatoPianta(
    vigore: vigore ?? this.vigore,
    ingiallimento: ingiallimento ?? this.ingiallimento,
    secchezza: secchezza ?? this.secchezza,
    marciume: marciume ?? this.marciume,
    spente: spente ?? this.spente,
    appassimento: appassimento ?? this.appassimento,
    caduta: caduta ?? this.caduta,
    bruciature: bruciature ?? this.bruciature,
    umiditaTerreno: umiditaTerreno ?? this.umiditaTerreno,
  );

  static StatoPianta lerp(StatoPianta a, StatoPianta b, double t) {
    double l(double x, double y) => lerpDouble(x, y, t)!;
    return StatoPianta(
      vigore: l(a.vigore, b.vigore),
      ingiallimento: l(a.ingiallimento, b.ingiallimento),
      secchezza: l(a.secchezza, b.secchezza),
      marciume: l(a.marciume, b.marciume),
      spente: l(a.spente, b.spente),
      appassimento: l(a.appassimento, b.appassimento),
      caduta: l(a.caduta, b.caduta),
      bruciature: l(a.bruciature, b.bruciature),
      umiditaTerreno: l(a.umiditaTerreno, b.umiditaTerreno),
    );
  }
}

/// Situazioni tipiche, positive e negative, con la luce consigliata per
/// mostrarle.
enum Scenario {
  sana(
    'Sana',
    StatoPianta(),
    0.6,
    'Foglie sode, verdi e lucide, con la variegatura ben visibile.',
    'Luce indiretta, acqua quando metà terriccio è asciutto.',
  ),
  rigogliosa(
    'Rigogliosa',
    StatoPianta(vigore: 1, umiditaTerreno: 0.55),
    0.75,
    'Tante foglie grandi e nuove punte verde chiaro: la pianta sta crescendo.',
    'Continua così; in primavera e estate concima una volta al mese.',
  ),
  troppaAcqua(
    'Troppa acqua',
    StatoPianta(
      ingiallimento: 0.6,
      marciume: 0.25,
      appassimento: 0.3,
      spente: 0.2,
      umiditaTerreno: 1,
    ),
    0.55,
    'Foglie gialle a partire dal basso, terriccio sempre bagnato.',
    'Sospendi le annaffiature finché metà terriccio è asciutto e svuota il sottovaso.',
  ),
  marciume(
    'Marciume radicale',
    StatoPianta(
      vigore: 0.5,
      ingiallimento: 0.45,
      marciume: 0.8,
      appassimento: 0.65,
      caduta: 0.25,
      spente: 0.3,
      umiditaTerreno: 1,
    ),
    0.5,
    'Fusti scuri e molli vicino al terriccio, foglie che anneriscono, odore di stantio.',
    'Togli la pianta dal vaso, taglia le radici marce e rinvasa in terriccio asciutto; salva qualche talea sana.',
  ),
  pocaAcqua(
    'Poca acqua',
    StatoPianta(
      secchezza: 0.6,
      appassimento: 0.85,
      caduta: 0.1,
      spente: 0.15,
      umiditaTerreno: 0,
    ),
    0.6,
    'Foglie flosce e cadenti, bordi secchi, terriccio chiaro e staccato dal vaso.',
    'Annaffia a fondo, anche per immersione: in poche ore le foglie si rialzano.',
  ),
  pocaLuce(
    'Poca luce',
    StatoPianta(vigore: 0.15, spente: 0.45, umiditaTerreno: 0.6),
    0.15,
    'Fusti lunghi con poche foglie piccole, la variegatura sparisce.',
    'Avvicinala a una finestra luminosa, senza sole diretto, e accorcia i fusti spogli.',
  ),
  troppoSole(
    'Troppo sole',
    StatoPianta(
      bruciature: 0.75,
      secchezza: 0.2,
      spente: 0.2,
      umiditaTerreno: 0.3,
    ),
    1,
    'Macchie chiare e secche sulle foglie più esposte.',
    'Spostala lontano dal sole diretto; le foglie bruciate non tornano verdi, si possono togliere.',
  ),
  freddo(
    'Freddo o correnti',
    StatoPianta(
      caduta: 0.45,
      spente: 0.35,
      appassimento: 0.25,
      ingiallimento: 0.2,
    ),
    0.5,
    'Foglie che cadono all\'improvviso, colori spenti.',
    'Tienila sopra i 15 °C, lontano da finestre aperte d\'inverno e da spifferi.',
  );

  const Scenario(
    this.etichetta,
    this.stato,
    this.luce,
    this.cosaVedi,
    this.cosaFare,
  );

  final String etichetta;
  final StatoPianta stato;

  /// Luce consigliata per la scena, da 0 (buio) a 1 (sole diretto).
  final double luce;
  final String cosaVedi;
  final String cosaFare;
}
