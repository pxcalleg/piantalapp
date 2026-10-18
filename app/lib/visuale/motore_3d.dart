import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'stato_pianta.dart';

/// Motore comune a tutte le piante interattive: stanza, vaso, terriccio,
/// proiezione 3D e disegno di fusti e foglie con i sintomi di
/// [StatoPianta]. Ogni [Specie] descrive solo la propria forma.
///
/// Coordinate: il vaso ha raggio 1 al bordo, che sta all'altezza y = 0;
/// y cresce verso l'alto.
class PiantaPainter extends CustomPainter {
  PiantaPainter({
    required this.specie,
    required this.stato,
    required this.rotazione,
    required this.luce,
  });

  final Specie specie;
  final StatoPianta stato;

  /// Angolo di rotazione attorno all'asse verticale, in radianti.
  final double rotazione;

  /// Luce della stanza, da 0 (buio) a 1 (sole pieno).
  final double luce;

  static const inclinazione = 0.38;

  Vaso get _vaso => specie.vaso;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = Camera(size, rotazione, inclinazione, specie.inquadratura);
    _disegnaStanza(canvas, size, cam);

    final c = Costruttore._(this, cam);
    specie.costruisci(c, stato);

    c._dietro.sort((a, b) => a.profondita.compareTo(b.profondita));
    c._davanti.sort((a, b) => a.profondita.compareTo(b.profondita));
    for (final e in c._dietro) {
      e.disegna(canvas);
    }
    _disegnaVaso(canvas, cam);
    for (final e in c._davanti) {
      e.disegna(canvas);
    }
  }

  @override
  bool shouldRepaint(PiantaPainter old) =>
      old.specie != specie ||
      old.stato != stato ||
      old.rotazione != rotazione ||
      old.luce != luce;

  // ---------------------------------------------------------------- stanza

  double get _luceScena => 0.45 + 0.65 * luce;

  void _disegnaStanza(Canvas canvas, Size size, Camera cam) {
    final rect = Offset.zero & size;
    final parete = Color.lerp(
      const Color(0xFF2B3036),
      const Color(0xFFF3EBDD),
      luce,
    )!;
    final paretePiede = Color.lerp(
      const Color(0xFF1E2226),
      const Color(0xFFE3D6C2),
      luce,
    )!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [parete, paretePiede],
        ).createShader(rect),
    );

    // Fascio di luce dalla finestra, in alto a sinistra.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-1.1, -1.1),
          radius: 1.4,
          colors: [
            Colors.white.withValues(alpha: 0.55 * luce),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    // Piano d'appoggio e ombra del vaso.
    final piano = cam.proietta(V3(0, -_vaso.altezza, 0)).dy;
    final rectPiano = Rect.fromLTRB(0, piano - 4, size.width, size.height);
    canvas.drawRect(
      rectPiano,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF2A241F),
          const Color(0xFFCDB89A),
          luce,
        )!,
    );
    final centroOmbra = cam.proietta(V3(0.35, -_vaso.altezza, -0.2));
    canvas.drawOval(
      Rect.fromCenter(
        center: centroOmbra,
        width: cam.unita * 2.6,
        height: cam.unita * 2.6 * math.sin(inclinazione) * 0.9,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12 + 0.25 * luce)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.unita * 0.12),
    );
  }

  // ------------------------------------------------------------------- vaso

  void _disegnaVaso(Canvas canvas, Camera cam) {
    final u = cam.unita;
    final schiaccia = math.sin(inclinazione);
    final centroAlto = cam.proietta(const V3(0, 0, 0));
    final centroBasso = cam.proietta(V3(0, -_vaso.altezza, 0));
    final sAlto = cam.scala(const V3(0, 0, 0));
    final sBasso = cam.scala(V3(0, -_vaso.altezza, 0));
    final rA = u * sAlto;
    final rB = u * _vaso.raggioFondo * sBasso;

    final corpo = Path()
      ..moveTo(centroAlto.dx - rA, centroAlto.dy)
      ..lineTo(centroBasso.dx - rB, centroBasso.dy)
      ..arcTo(
        Rect.fromCenter(
          center: centroBasso,
          width: rB * 2,
          height: rB * 2 * schiaccia,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(centroAlto.dx + rA, centroAlto.dy)
      ..close();
    final tinta = illumina(_vaso.colore, 1);
    canvas.drawPath(
      corpo,
      Paint()
        ..shader = LinearGradient(
          colors: [schiarisci(tinta, 0.18), tinta, scurisci(tinta, 0.45)],
          stops: const [0, 0.45, 1],
        ).createShader(corpo.getBounds()),
    );
    if (_vaso.lucido) {
      // Riflesso verticale della ceramica smaltata.
      final b = corpo.getBounds();
      canvas.save();
      canvas.clipPath(corpo);
      canvas.drawRect(
        Rect.fromLTWH(b.left + b.width * 0.2, b.top, b.width * 0.07, b.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1 + 0.25 * luce)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, b.width * 0.02),
      );
      canvas.restore();
    }

    // Terriccio, appena sotto il bordo.
    final centroTerra = cam.proietta(const V3(0, -0.07, 0));
    final rT = rA * 0.95;
    final ovaleTerra = Rect.fromCenter(
      center: centroTerra,
      width: rT * 2,
      height: rT * 2 * schiaccia,
    );
    final terra = illumina(
      Color.lerp(
        const Color(0xFFA88462),
        const Color(0xFF33251B),
        stato.umiditaTerreno,
      )!,
      1,
    );
    canvas.drawOval(ovaleTerra, Paint()..color = terra);
    _dettagliTerra(canvas, ovaleTerra);

    // Bordo del vaso: anello spesso con riflesso.
    final ovaleBordo = Rect.fromCenter(
      center: centroAlto,
      width: rA * 2.08,
      height: rA * 2.08 * schiaccia,
    );
    canvas.drawOval(
      ovaleBordo,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.11
        ..color = schiarisci(tinta, 0.08),
    );
    canvas.drawArc(
      ovaleBordo,
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.03
        ..color = Colors.white.withValues(alpha: 0.12 + 0.2 * luce),
    );
  }

  void _dettagliTerra(Canvas canvas, Rect ovale) {
    final rnd = math.Random(7);
    canvas.save();
    canvas.clipPath(Path()..addOval(ovale));
    // Granelli e perlite.
    for (var i = 0; i < 60; i++) {
      final p = Offset(
        ovale.left + rnd.nextDouble() * ovale.width,
        ovale.top + rnd.nextDouble() * ovale.height,
      );
      final chiaro = rnd.nextDouble() < 0.25;
      canvas.drawCircle(
        p,
        ovale.width * (chiaro ? 0.012 : 0.008),
        Paint()
          ..color = chiaro
              ? Colors.white.withValues(alpha: 0.55)
              : Colors.black.withValues(alpha: 0.18),
      );
    }
    // Terriccio asciutto: crepe.
    final asciutto = ((0.3 - stato.umiditaTerreno) / 0.3).clamp(0.0, 1.0);
    if (asciutto > 0) {
      final crepa = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ovale.width * 0.006
        ..color = Colors.black.withValues(alpha: 0.35 * asciutto);
      for (var i = 0; i < 7; i++) {
        var p = Offset(
          ovale.left + rnd.nextDouble() * ovale.width,
          ovale.top + rnd.nextDouble() * ovale.height,
        );
        final path = Path()..moveTo(p.dx, p.dy);
        for (var k = 0; k < 4; k++) {
          p += Offset(
            (rnd.nextDouble() - 0.5) * ovale.width * 0.18,
            (rnd.nextDouble() - 0.5) * ovale.height * 0.18,
          );
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, crepa);
      }
    }
    // Ristagno e muffa bianca con marciume.
    final muffa =
        (stato.marciume - 0.3).clamp(0.0, 1.0) *
        ((stato.umiditaTerreno - 0.6) / 0.4).clamp(0.0, 1.0);
    if (muffa > 0) {
      for (var i = 0; i < 25; i++) {
        canvas.drawCircle(
          Offset(
            ovale.left + rnd.nextDouble() * ovale.width,
            ovale.top + rnd.nextDouble() * ovale.height,
          ),
          ovale.width * (0.01 + rnd.nextDouble() * 0.02),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.5 * muffa)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              ovale.width * 0.01,
            ),
        );
      }
    }
    canvas.restore();
  }

  // ----------------------------------------------------------------- colori

  Color illumina(Color c, double intensita) {
    final l = _luceScena * intensita;
    return l <= 1
        ? Color.lerp(Colors.black, c, l)!
        : Color.lerp(c, Colors.white, (l - 1) * 0.35)!;
  }

  static Color schiarisci(Color c, double q) => Color.lerp(c, Colors.white, q)!;
  static Color scurisci(Color c, double q) => Color.lerp(c, Colors.black, q)!;

  Color _coloreFoglia(Foglia f, Sintomi m, double luceDiretta, bool retro) {
    var c = f.colore ?? (f.nuova ? specie.colori.nuova : specie.colori.base);
    if (retro && f.colore == null) {
      c = Color.lerp(c, specie.colori.retro, 0.55)!;
    }
    c = Color.lerp(c, const Color(0xFFD9C24A), m.gialla)!;
    c = Color.lerp(c, const Color(0xFF8A8F70), stato.spente * 0.65)!;
    c = Color.lerp(
      c,
      const Color(0xFF9B7045),
      ((m.secca - 0.45) / 0.55).clamp(0.0, 1.0),
    )!;
    if (!specie.marciumeAMacchie) {
      c = Color.lerp(c, const Color(0xFF2E2116), m.marcia * 0.85)!;
    }
    // I fiori chiari restano luminosi anche in ombra.
    final minimo = f.colore != null ? 0.85 : 0.6;
    return illumina(c, minimo + 0.5 * luceDiretta);
  }
}

// ------------------------------------------------------------------ specie

/// Quanto spazio occupa la scena, in unità del vaso sullo schermo: metà
/// larghezza, punto più alto e punto più basso.
class Inquadratura {
  const Inquadratura({
    required this.mezzaLarghezza,
    required this.alto,
    required this.basso,
  });

  final double mezzaLarghezza, alto, basso;
}

class Vaso {
  const Vaso({
    this.altezza = 1.45,
    this.raggioFondo = 0.74,
    this.colore = terracotta,
    this.lucido = false,
  });

  static const terracotta = Color(0xFFB4643A);
  static const ceramicaChiara = Color(0xFFE9E2D6);
  static const antracite = Color(0xFF51565C);
  static const salvia = Color(0xFF9DAA8F);

  final double altezza, raggioFondo;
  final Color colore;
  final bool lucido;
}

class ColoriFoglia {
  const ColoriFoglia({
    required this.base,
    required this.nuova,
    required this.retro,
  });

  final Color base, nuova;

  /// Pagina inferiore, di solito più chiara e opaca.
  final Color retro;
}

typedef TestoScenario = ({String vedi, String fare});

/// Forma e carattere di una pianta interattiva.
abstract class Specie {
  const Specie();

  Inquadratura get inquadratura;
  Vaso get vaso => const Vaso();
  ColoriFoglia get colori;

  /// Quanto brillano le foglie sane, da 0 (opache) a 1 (lucidissime).
  double get lucentezza => 0.6;

  /// Le foglie malate cadono a terra; se false restano attaccate e la
  /// specie decide come piegarle.
  bool get foglieCadono => true;

  /// Quota di foglie cadute da disegnare a terra, per non coprire il
  /// pavimento quando le foglie sono tante e piccole.
  double get quotaATerra => 1;

  /// Il marciume compare come macchie scure sulla lamina invece che come
  /// annerimento dalla base.
  bool get marciumeAMacchie => false;

  Map<Scenario, TestoScenario> get testi;

  void costruisci(Costruttore c, StatoPianta s);
}

// ------------------------------------------------------------- costruttore

/// Sintomi di una singola foglia, da 0 a 1.
class Sintomi {
  const Sintomi({
    this.gialla = 0,
    this.secca = 0,
    this.marcia = 0,
    this.bruciata = 0,
    this.cade = false,
    this.variegatura = 0,
  });

  final double gialla, secca, marcia, bruciata;
  final bool cade;

  /// Valore casuale stabile per i disegni sulla foglia.
  final double variegatura;
}

enum Forma {
  /// Cuore, come il pothos.
  cuore([
    (0, 0),
    (-0.12, 0.48),
    (-0.04, 0.88),
    (0.14, 1),
    (0.34, 0.94),
    (0.56, 0.74),
    (0.76, 0.45),
    (0.9, 0.2),
    (1, 0),
  ]),

  /// Ellittica con punta allungata, come il Ficus benjamina.
  ellittica([
    (0, 0),
    (0.06, 0.5),
    (0.22, 0.88),
    (0.42, 1),
    (0.62, 0.88),
    (0.8, 0.55),
    (0.92, 0.2),
    (1, 0),
  ]),

  /// Ovale larga e arrotondata, come il Ficus robusta.
  ovale([
    (0, 0),
    (0.03, 0.45),
    (0.15, 0.85),
    (0.4, 1),
    (0.65, 0.93),
    (0.85, 0.65),
    (0.96, 0.3),
    (1, 0),
  ]),

  /// A violino: stretta in basso e larga in alto, come il Ficus lyrata.
  violino([
    (0, 0),
    (0.04, 0.32),
    (0.18, 0.5),
    (0.36, 0.56),
    (0.52, 0.74),
    (0.7, 0.96),
    (0.84, 1),
    (0.95, 0.72),
    (1, 0.3),
    (1.01, 0),
  ]),

  /// Lunga lama piatta, come la sansevieria.
  spada([
    (0, 0.55),
    (0.05, 0.85),
    (0.3, 1),
    (0.6, 0.98),
    (0.84, 0.75),
    (0.95, 0.35),
    (1, 0),
  ]),

  /// Ovale piccola e piena, come la fittonia.
  ovalePiccola([
    (0, 0),
    (0.04, 0.5),
    (0.2, 0.88),
    (0.45, 1),
    (0.7, 0.85),
    (0.9, 0.45),
    (1, 0),
  ]),

  /// Lanceolata, come lo spatifillo.
  lanceolata([
    (0, 0),
    (0.06, 0.4),
    (0.25, 0.85),
    (0.48, 1),
    (0.72, 0.8),
    (0.9, 0.38),
    (1, 0),
  ]),

  /// Spata del fiore dello spatifillo.
  spata([
    (0, 0),
    (0.08, 0.6),
    (0.3, 0.95),
    (0.52, 1),
    (0.75, 0.7),
    (0.92, 0.28),
    (1, 0),
  ]),

  /// Guaina sottile e appuntita in cima ai fusti del Ficus robusta.
  guaina([(0, 0.6), (0.3, 1), (0.7, 0.7), (1, 0)]),

  /// Larga alla base e affusolata in punta, come l'aloe e l'haworthia.
  triangolo([
    (0, 0.8),
    (0.12, 1),
    (0.35, 0.86),
    (0.6, 0.6),
    (0.85, 0.28),
    (1, 0),
  ]),

  /// A spatola con punta corta, come le foglie dell'echeveria.
  spatola([
    (0, 0.3),
    (0.25, 0.6),
    (0.5, 0.86),
    (0.72, 1),
    (0.88, 0.85),
    (0.97, 0.4),
    (1, 0),
  ]);

  const Forma(this.punti);

  /// Mezzo contorno (u lungo la nervatura, w larghezza da 0 a 1).
  final List<(double, double)> punti;

  double larghezzaA(double u) {
    if (u <= punti.first.$1) return punti.first.$2;
    for (var i = 1; i < punti.length; i++) {
      final (u1, w1) = punti[i];
      if (u <= u1) {
        final (u0, w0) = punti[i - 1];
        return w0 + (w1 - w0) * (u - u0) / (u1 - u0);
      }
    }
    return 0;
  }
}

/// Disegni sulla lamina.
enum Motivo {
  nessuno,

  /// Striature dorate che spariscono con poca luce.
  pothos,

  /// Solo la nervatura centrale chiara.
  centrale,

  /// Nervatura centrale chiara e laterali sottili e fitte.
  robusta,

  /// Nervature chiare e marcate, a spina di pesce.
  lyrata,

  /// Fasce trasversali chiare e bordo giallo.
  sansevieria,

  /// Rete di venature bianche.
  fittonia,

  /// Nervature laterali parallele e incavate.
  spatifillo,

  /// Macchioline chiare e dentini sul bordo; al sole forte si arrossa.
  aloe,

  /// Fasce trasversali di tubercoli bianchi; al sole forte si arrossa.
  haworthia,

  /// Bordo rosso che si accende con tanta luce.
  crassula,

  /// Punta rosata e pruina chiara.
  echeveria,

  /// Areole con spine bianche a stella.
  cactus,

  /// Ciuffi di glochidi gialli in file oblique.
  opuntia,
}

class Foglia {
  const Foglia({
    this.picciolo,
    required this.base,
    required this.controllo,
    required this.punta,
    required this.larghezza,
    required this.forma,
    this.motivo = Motivo.centrale,
    required this.eta,
    required this.seme,
    this.nuova = false,
    this.lato,
    this.colore,
    this.coppa = 0.25,
    this.rollio = 0,
    this.sintomi,
  });

  /// Inizio del picciolo; se presente si disegna fino a [base].
  final V3? picciolo;

  /// Nervatura centrale come curva di Bézier quadratica.
  final V3 base, controllo, punta;

  /// Mezza larghezza massima in frazione della lunghezza.
  final double larghezza;
  final Forma forma;
  final Motivo motivo;

  /// 0 = foglia vecchia (si ammala per prima), 1 = appena spuntata.
  final double eta;
  final int seme;
  final bool nuova;

  /// Direzione della larghezza; se manca è orizzontale.
  final V3? lato;

  /// Colore che sostituisce quello della specie (per esempio un fiore).
  final Color? colore;

  /// Quanto la lamina si piega a doccia lungo la nervatura.
  final double coppa;

  /// Rotazione della lamina attorno alla nervatura, in radianti: le foglie
  /// vere non sono mai tutte orizzontali.
  final double rollio;

  /// Sintomi già calcolati dalla specie; se mancano li calcola il motore.
  final Sintomi? sintomi;
}

/// Raccoglie fusti e foglie generati da una [Specie] per un fotogramma.
class Costruttore {
  Costruttore._(this._pittore, this.cam);

  final PiantaPainter _pittore;
  final Camera cam;
  final _dietro = <_Elemento>[];
  final _davanti = <_Elemento>[];

  StatoPianta get stato => _pittore.stato;
  double get luce => _pittore.luce;
  double get altezzaVaso => _pittore._vaso.altezza;

  void _aggiungi(_Elemento e) => (e.nascosto ? _dietro : _davanti).add(e);

  /// Sintomi di una foglia: le più vecchie si ammalano per prime.
  Sintomi sintomi(int seme, double eta) {
    final s = stato;
    final rnd = math.Random(seme * 7919 + 13);
    final u1 = rnd.nextDouble(), u2 = rnd.nextDouble(), u3 = rnd.nextDouble();
    final priorita = 0.45 * u1 + 0.55 * eta;
    double quota(double livello, double p) =>
        ((livello * 1.15 - p) / 0.18).clamp(0.0, 1.0);
    return Sintomi(
      gialla: quota(s.ingiallimento, priorita),
      secca: quota(s.secchezza, 0.5 * u2 + 0.5 * eta),
      marcia: quota(s.marciume, 0.3 * u1 + 0.7 * eta),
      bruciata: quota(s.bruciature, 0.4 * u3 + 0.6 * (1 - eta)),
      cade: quota(s.caduta, priorita) > 0.5,
      variegatura: u2,
    );
  }

  /// Sposta un punto perché non attraversi il vaso né il pavimento.
  V3 fuoriDalVaso(V3 p) {
    var y = p.y;
    if (math.sqrt(p.x * p.x + p.z * p.z) < 1.08) y = math.max(y, -0.04);
    y = math.max(y, -altezzaVaso + 0.03);
    return V3(p.x, y, p.z);
  }

  /// Fusto o ramo come spezzata; lo spessore va da [spessore] a
  /// [spessoreFinale] in unità del vaso. Con [marcisce] il marciume lo
  /// annerisce a partire dalla base.
  void fusto(
    List<V3> punti, {
    required double spessore,
    double? spessoreFinale,
    required Color colore,
    bool marcisce = false,
  }) {
    final s = stato;
    final fine = spessoreFinale ?? spessore * 0.65;
    final n = punti.length - 1;
    for (var i = 0; i < n; i++) {
      final a = punti[i], b = punti[i + 1];
      final t = i / n;
      final marcio = marcisce
          ? (s.marciume * 1.3 - t * 2).clamp(0.0, 1.0)
          : (s.marciume - 0.4).clamp(0.0, 1.0) * (1 - t) * 0.6;
      final c = Color.lerp(
        Color.lerp(colore, const Color(0xFF8A8A5C), s.spente * 0.5)!,
        const Color(0xFF2B1D12),
        marcio,
      )!;
      final m = a.medio(b);
      _aggiungi(
        _Segmento(
          cam.proietta(a),
          cam.proietta(b),
          _pittore.illumina(c, 0.9),
          cam.unita *
              (spessore + (fine - spessore) * t) *
              (cam.scala(a) + cam.scala(b)) /
              2,
          cam.profondita(m),
          _dietroAlVaso(m),
        ),
      );
    }
  }

  void foglia(Foglia f) {
    final m = f.sintomi ?? sintomi(f.seme, f.eta);
    if (m.cade && _pittore.specie.foglieCadono) {
      _aTerra(f, m);
      return;
    }
    if (f.picciolo != null) {
      final c = _pittore._coloreFoglia(f, m, 0.3, false);
      final mid = f.picciolo!.medio(f.base);
      _aggiungi(
        _Segmento(
          cam.proietta(f.picciolo!),
          cam.proietta(f.base),
          c,
          cam.unita * 0.018 * cam.scala(mid),
          cam.profondita(mid) - 0.001,
          _dietroAlVaso(mid),
        ),
      );
    }
    _aggiungi(
      _ElementoFoglia(
        f,
        m,
        _pittore,
        cam,
        _dietroAlVaso(f.base.medio(f.punta)),
      ),
    );
  }

  void _aTerra(Foglia f, Sintomi m) {
    final rnd = math.Random(f.seme * 31 + 5);
    if (rnd.nextDouble() > _pittore.specie.quotaATerra) return;
    final lunghezza = (f.punta - f.base).lunghezza;
    final a = math.atan2(f.base.z, f.base.x) + (rnd.nextDouble() - 0.5) * 1.6;
    final r = 1.05 + rnd.nextDouble() * 0.75;
    final y = -altezzaVaso + 0.01;
    final base = V3(r * math.cos(a), y, r * math.sin(a));
    final dirA = rnd.nextDouble() * math.pi * 2;
    final dir = V3(math.cos(dirA), 0.04, math.sin(dirA));
    final caduta = Foglia(
      base: base,
      controllo: base + dir * (lunghezza * 0.5),
      punta: base + dir * lunghezza,
      larghezza: f.larghezza,
      forma: f.forma,
      motivo: f.motivo,
      eta: f.eta,
      seme: f.seme,
      colore: f.colore,
      coppa: 0.1,
    );
    final mt = Sintomi(
      gialla: 0.9,
      secca: 0.4 + 0.5 * rnd.nextDouble(),
      marcia: stato.marciume * 0.6,
      variegatura: m.variegatura,
    );
    _aggiungi(
      _ElementoFoglia(caduta, mt, _pittore, cam, cam.profondita(base) < -0.2),
    );
  }

  bool _dietroAlVaso(V3 p) {
    if (p.y > -0.04) return false;
    return cam.profondita(p) < 0;
  }
}

// ------------------------------------------------------------------ geometria

class V3 {
  const V3(this.x, this.y, this.z);
  final double x, y, z;

  static const su = V3(0, 1, 0);

  /// Punto in coordinate cilindriche attorno all'asse del vaso.
  factory V3.cilindro(double angolo, double raggio, double y) =>
      V3(raggio * math.cos(angolo), y, raggio * math.sin(angolo));

  V3 operator +(V3 o) => V3(x + o.x, y + o.y, z + o.z);
  V3 operator -(V3 o) => V3(x - o.x, y - o.y, z - o.z);
  V3 operator -() => V3(-x, -y, -z);
  V3 operator *(double k) => V3(x * k, y * k, z * k);
  double dot(V3 o) => x * o.x + y * o.y + z * o.z;
  V3 cross(V3 o) => V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get lunghezza => math.sqrt(dot(this));
  V3 normalizzato() {
    final l = lunghezza;
    return l < 1e-9 ? su : this * (1 / l);
  }

  V3 medio(V3 o) => (this + o) * 0.5;

  /// Componente orizzontale, normalizzata.
  V3 orizzontale() => V3(x, 0, z).normalizzato();

  static V3 bezier(V3 a, V3 c, V3 b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);
}

class Camera {
  Camera(Size size, double rotazione, double inclinazione, Inquadratura q)
    : _cosR = math.cos(rotazione),
      _sinR = math.sin(rotazione),
      _cosI = math.cos(inclinazione),
      _sinI = math.sin(inclinazione),
      unita = _unita(size, q),
      centro = Offset(
        size.width / 2,
        size.height / 2 + (q.alto + q.basso) / 2 * _unita(size, q),
      );

  static double _unita(Size size, Inquadratura q) => math.min(
    size.width / (2 * q.mezzaLarghezza),
    size.height / (q.alto - q.basso),
  );

  final double _cosR, _sinR, _cosI, _sinI;
  final double unita;
  final Offset centro;
  static const _fuoco = 7.0;

  /// Luce in coordinate di camera: dall'alto a sinistra, dalla finestra.
  static final direzioneLuce = const V3(-0.55, 0.75, 0.45).normalizzato();

  V3 vista(V3 p) {
    final x = p.x * _cosR + p.z * _sinR;
    final z = -p.x * _sinR + p.z * _cosR;
    return V3(x, p.y * _cosI - z * _sinI, p.y * _sinI + z * _cosI);
  }

  double scala(V3 p) => _fuoco / (_fuoco - vista(p).z);
  double profondita(V3 p) => vista(p).z;

  Offset proietta(V3 p) {
    final v = vista(p);
    final s = _fuoco / (_fuoco - v.z);
    return Offset(centro.dx + v.x * s * unita, centro.dy - v.y * s * unita);
  }
}

// ---------------------------------------------------------------- elementi

abstract class _Elemento {
  double get profondita;
  bool get nascosto;
  void disegna(Canvas canvas);
}

class _Segmento implements _Elemento {
  _Segmento(
    this.a,
    this.b,
    this.colore,
    this.spessore,
    this.profondita,
    this.nascosto,
  );

  final Offset a, b;
  final Color colore;
  final double spessore;
  @override
  final double profondita;
  @override
  final bool nascosto;

  @override
  void disegna(Canvas canvas) => canvas.drawLine(
    a,
    b,
    Paint()
      ..color = colore
      ..strokeWidth = spessore
      ..strokeCap = StrokeCap.round,
  );
}

class _ElementoFoglia implements _Elemento {
  _ElementoFoglia(this.f, this.m, this.pittore, this.cam, this.nascosto)
    : profondita = cam.profondita(f.base.medio(f.punta));

  final Foglia f;
  final Sintomi m;
  final PiantaPainter pittore;
  final Camera cam;
  @override
  final double profondita;
  @override
  final bool nascosto;

  @override
  void disegna(Canvas canvas) {
    final stato = pittore.stato;
    final asse = f.punta - f.base;
    final lunghezza = asse.lunghezza;
    if (lunghezza < 1e-6) return;
    final dir = asse * (1 / lunghezza);
    var lato = f.lato ?? V3.su.cross(dir);
    lato = lato - dir * lato.dot(dir);
    if (lato.lunghezza < 0.15) lato = const V3(1, 0, 0).cross(dir);
    lato = lato.normalizzato();
    if (f.rollio != 0) {
      lato = lato * math.cos(f.rollio) + dir.cross(lato) * math.sin(f.rollio);
    }

    V3 spina(double u) => V3.bezier(f.base, f.controllo, f.punta, u);
    final tangente =
        (f.controllo - f.base) * 0.5 + (f.punta - f.controllo) * 0.5;
    var normale = lato.cross(tangente).normalizzato();
    if (normale.y < 0) normale = -normale;

    // Lato visibile e luce che riceve.
    var nVista = cam.vista(normale) - cam.vista(const V3(0, 0, 0));
    final retro = nVista.z < 0 && normale.y > 0.25;
    if (nVista.z < 0) nVista = -nVista;
    final luceDiretta = math.max(0.0, nVista.dot(Camera.direzioneLuce));

    // Le foglie secche o mosce si accartocciano e si restringono.
    final arriccia = 1 - 0.45 * m.secca - 0.25 * stato.appassimento;
    final mezza = f.larghezza * lunghezza * arriccia;

    Offset q(double u, double v) {
      final w = f.forma.larghezzaA(u) * mezza;
      return cam.proietta(
        spina(u) + lato * (v * w) + normale * (w * v.abs() * f.coppa),
      );
    }

    final punti = f.forma.punti;
    final sinistra = [for (final (u, _) in punti) q(u, 1)];
    final destra = [for (final (u, _) in punti) q(u, -1)];
    final contorno = [...sinistra, ...destra.reversed];
    final path = Path()..moveTo(contorno.first.dx, contorno.first.dy);
    for (var i = 1; i < contorno.length; i++) {
      final a = contorno[i];
      final b = contorno[(i + 1) % contorno.length];
      path.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    }
    path.close();

    final px = lunghezza * cam.unita * cam.scala(f.base);
    final pxLargo = px * f.larghezza;
    final colore = pittore._coloreFoglia(f, m, luceDiretta, retro);
    canvas.drawPath(path, Paint()..color = colore);

    canvas.save();
    canvas.clipPath(path);
    _motivo(canvas, q, px, pxLargo);

    // Bruciature da sole: chiazze chiare.
    if (m.bruciata > 0.02) {
      final rnd = math.Random(f.seme + 3);
      for (var i = 0; i < 2; i++) {
        final c = q(
          0.35 + rnd.nextDouble() * 0.4,
          (rnd.nextDouble() - 0.5) * 0.9,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: c,
            width: pxLargo * 1.1,
            height: pxLargo * 0.8,
          ),
          Paint()
            ..color = const Color(0xFFE2D3A6)
                .withValues(alpha: 0.85 * m.bruciata)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, pxLargo * 0.12),
        );
      }
    }

    // Marciume: chiazza scura dalla base, oppure macchie sulla lamina.
    if (m.marcia > 0.02) {
      final scuro = const Color(0xFF2A1A0E);
      if (pittore.specie.marciumeAMacchie) {
        final rnd = math.Random(f.seme + 7);
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            q(0.3 + rnd.nextDouble() * 0.45, (rnd.nextDouble() - 0.5) * 0.8),
            pxLargo * (0.25 + 0.55 * m.marcia) * (0.6 + 0.6 * rnd.nextDouble()),
            Paint()
              ..color = scuro.withValues(alpha: 0.8 * m.marcia)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, pxLargo * 0.12),
          );
        }
      } else {
        canvas.drawCircle(
          q(0, 0),
          math.min(px, pxLargo * 6) * (0.2 + 0.6 * m.marcia),
          Paint()
            ..color = scuro.withValues(alpha: 0.7 * m.marcia)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, pxLargo * 0.5),
        );
      }
    }

    // Punte secche.
    if (m.secca > 0.05) {
      canvas.drawCircle(
        q(1, 0),
        math.min(px * 0.3, pxLargo * 2.2) * m.secca,
        Paint()
          ..color = pittore.illumina(const Color(0xFF8A5C34), 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, pxLargo * 0.15),
      );
    }
    canvas.restore();

    // Bordo sottile per staccare la foglia dallo sfondo, e bordi secchi.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, pxLargo * 0.03)
        ..color = Colors.black.withValues(alpha: 0.12),
    );
    if (m.secca > 0.02) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = pxLargo * 0.15 * m.secca
          ..color = pittore.illumina(const Color(0xFF7A5230), 0.9),
      );
    }

    // Lucentezza delle foglie sane.
    final lucido =
        pittore.specie.lucentezza *
        (1 - m.secca) *
        (1 - stato.spente) *
        (1 - m.marcia);
    if (lucido > 0.15 && f.colore == null) {
      canvas.drawLine(
        q(0.22, 0.35),
        q(0.62, 0.3),
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.28 * lucido * pittore.luce * (0.4 + luceDiretta),
          )
          ..strokeWidth = pxLargo * 0.16
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _motivo(
    Canvas canvas,
    Offset Function(double, double) q,
    double px,
    double pxLargo,
  ) {
    final stato = pittore.stato;
    final rnd = math.Random(f.seme);
    Paint tratto(Color c, double spessore) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(0.5, spessore)
      ..color = c;
    void linea(Paint p, List<(double, double)> uv) {
      final path = Path();
      final a = q(uv.first.$1, uv.first.$2);
      path.moveTo(a.dx, a.dy);
      if (uv.length == 2) {
        final b = q(uv[1].$1, uv[1].$2);
        path.lineTo(b.dx, b.dy);
      } else {
        for (var i = 1; i < uv.length - 1; i++) {
          final c = q(uv[i].$1, uv[i].$2);
          final n = q(uv[i + 1].$1, uv[i + 1].$2);
          final fine = i == uv.length - 2
              ? n
              : Offset((c.dx + n.dx) / 2, (c.dy + n.dy) / 2);
          path.quadraticBezierTo(c.dx, c.dy, fine.dx, fine.dy);
        }
      }
      canvas.drawPath(path, p);
    }

    // Quanto restano visibili i colori del disegno.
    final vivo =
        (1 - stato.spente * 0.7) * (1 - m.marcia) * (1 - m.gialla * 0.6);

    void centrale(Color c, double alpha, double spessore) => linea(
      tratto(c.withValues(alpha: alpha * vivo), spessore),
      [(0, 0), (0.5, 0), (0.94, 0)],
    );

    void laterali(
      Color c,
      double alpha,
      double spessore,
      int coppie,
      double inclinazione,
      double arrivo,
    ) {
      final p = tratto(c.withValues(alpha: alpha * vivo), spessore);
      for (var i = 0; i < coppie; i++) {
        final u0 = 0.08 + 0.8 * i / coppie;
        for (final lato in const [1.0, -1.0]) {
          linea(p, [
            (u0, 0),
            (u0 + inclinazione * 0.5, lato * arrivo * 0.55),
            (u0 + inclinazione, lato * arrivo),
          ]);
        }
      }
    }

    switch (f.motivo) {
      case Motivo.nessuno:
        break;
      case Motivo.pothos:
        final varieg =
            ((pittore.luce - 0.2) / 0.35).clamp(0.0, 1.0) *
            (1 - stato.spente) *
            (1 - m.marcia) *
            (1 - m.gialla * 0.7) *
            (0.35 + 0.65 * m.variegatura);
        if (varieg > 0.02) {
          final pv = tratto(
            const Color(0xFFF1E59A).withValues(alpha: 0.55 * varieg),
            pxLargo * 0.13,
          );
          for (var i = 0; i < 4; i++) {
            final v0 = (rnd.nextDouble() - 0.5) * 1.1;
            final v1 = v0 + (rnd.nextDouble() - 0.5) * 0.8;
            linea(pv, [(0.05, v0 * 0.3), (0.45, v0), (0.85, v1 * 0.5)]);
          }
        }
        centrale(Colors.white, 0.18, px * 0.025);
      case Motivo.centrale:
        centrale(Colors.white, 0.22, px * 0.02);
      case Motivo.robusta:
        laterali(Colors.white, 0.06, px * 0.006, 14, 0.12, 0.92);
        centrale(const Color(0xFFE8E0C0), 0.5, px * 0.022);
      case Motivo.lyrata:
        laterali(const Color(0xFFD8E39A), 0.38, px * 0.01, 5, 0.18, 0.85);
        centrale(const Color(0xFFDDE6A2), 0.6, px * 0.022);
      case Motivo.sansevieria:
        final fascia = tratto(
          const Color(0xFFA9BC95).withValues(alpha: 0.55 * vivo),
          px * 0.012,
        );
        for (var u = 0.04; u < 0.95; u += 0.045 + rnd.nextDouble() * 0.03) {
          final d = 0.015 + rnd.nextDouble() * 0.02;
          linea(fascia, [
            (u, -1),
            (u + d, -0.5),
            (u - d, 0),
            (u + d, 0.5),
            (u, 1),
          ]);
        }
        // Bordo giallo della varietà Laurentii.
        final bordo = tratto(
          const Color(0xFFD9C45A).withValues(alpha: 0.8 * vivo),
          pxLargo * 0.25,
        );
        for (final lato in const [1.0, -1.0]) {
          linea(bordo, [
            for (var u = 0.0; u <= 1.0; u += 0.1) (u, lato * 0.97),
          ]);
        }
      case Motivo.fittonia:
        final vena = tratto(
          const Color(0xFFF4F1E4).withValues(alpha: 0.9 * vivo),
          px * 0.018,
        );
        linea(vena, [(0, 0), (0.5, 0), (0.95, 0)]);
        const coppie = 5;
        for (var i = 0; i < coppie; i++) {
          final u0 = 0.1 + 0.78 * i / coppie;
          for (final lato in const [1.0, -1.0]) {
            linea(vena, [
              (u0, 0),
              (u0 + 0.08, lato * 0.5),
              (u0 + 0.2, lato * 0.92),
            ]);
          }
        }
        // Rete sottile tra le venature.
        final rete = tratto(
          const Color(0xFFF4F1E4).withValues(alpha: 0.6 * vivo),
          px * 0.008,
        );
        for (var i = 0; i < coppie; i++) {
          final u0 = 0.14 + 0.78 * i / coppie;
          for (final lato in const [1.0, -1.0]) {
            linea(rete, [(u0, lato * 0.3), (u0 + 0.16, lato * 0.38)]);
            linea(rete, [(u0 + 0.05, lato * 0.62), (u0 + 0.2, lato * 0.68)]);
          }
        }
      case Motivo.spatifillo:
        laterali(Colors.black, 0.18, px * 0.008, 9, 0.22, 0.95);
        centrale(const Color(0xFFCFE0B0), 0.45, px * 0.018);
      case Motivo.aloe:
        _arrossa(canvas, q, pxLargo);
        final macchia = Paint()
          ..color = const Color(0xFFDDE8CC).withValues(alpha: 0.5 * vivo);
        for (var i = 0; i < 16; i++) {
          final c = q(
            0.08 + rnd.nextDouble() * 0.7,
            (rnd.nextDouble() - 0.5) * 1.4,
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: c,
              width: pxLargo * 0.16,
              height: pxLargo * 0.09,
            ),
            macchia,
          );
        }
        final dente = Paint()
          ..color = const Color(0xFFEDE6C4).withValues(alpha: 0.8 * vivo);
        for (var u = 0.06; u < 0.9; u += 0.07) {
          for (final lato in const [1.0, -1.0]) {
            canvas.drawCircle(q(u, lato * 0.93), pxLargo * 0.055, dente);
          }
        }
      case Motivo.haworthia:
        _arrossa(canvas, q, pxLargo);
        final tubercolo = Paint()
          ..color = const Color(0xFFEFF1E8).withValues(alpha: 0.85 * vivo);
        var riga = 0;
        for (var u = 0.06; u < 0.9; u += 0.075) {
          final sfasa = riga.isEven ? 0.0 : 0.14;
          for (var v = -0.84 + sfasa; v <= 0.86; v += 0.28) {
            canvas.drawCircle(q(u, v), pxLargo * 0.075, tubercolo);
          }
          riga++;
        }
      case Motivo.crassula:
        final bordo = tratto(
          const Color(0xFFB8433A)
              .withValues(alpha: (0.1 + 0.55 * pittore.luce) * vivo),
          pxLargo * 0.12,
        );
        for (final lato in const [1.0, -1.0]) {
          linea(bordo, [
            for (var u = 0.0; u <= 1.0; u += 0.1) (u, lato * 0.98),
          ]);
        }
      case Motivo.echeveria:
        canvas.drawCircle(
          q(1, 0),
          pxLargo * 0.6,
          Paint()
            ..color = const Color(0xFFD48A9C)
                .withValues(alpha: (0.15 + 0.35 * pittore.luce) * vivo)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, pxLargo * 0.3),
        );
        centrale(Colors.white, 0.14, px * 0.03);
      case Motivo.cactus:
        final spina = tratto(
          const Color(0xFFF3F0E2).withValues(alpha: 0.85 * vivo),
          pxLargo * 0.025,
        );
        final areola = Paint()
          ..color = const Color(0xFFFFFFF4).withValues(alpha: 0.9 * vivo);
        var riga = 0;
        for (var u = 0.06; u < 0.95; u += 0.07) {
          for (final v in riga.isEven ? const [-0.5, 0.5] : const [0.0]) {
            final c = q(u, v);
            final r = pxLargo * 0.2;
            for (var a = 0; a < 6; a++) {
              final ang = a * math.pi / 3 + riga * 0.4;
              canvas.drawLine(
                c,
                c + Offset(math.cos(ang) * r, math.sin(ang) * r),
                spina,
              );
            }
            canvas.drawCircle(c, pxLargo * 0.045, areola);
          }
          riga++;
        }
      case Motivo.opuntia:
        final ciuffo = Paint()
          ..color = const Color(0xFFE9D47C).withValues(alpha: 0.95 * vivo);
        final centro = Paint()
          ..color = const Color(0xFF9C7A3A).withValues(alpha: 0.6 * vivo);
        var riga = 0;
        for (var u = 0.08; u < 0.95; u += 0.1) {
          final sfasa = riga.isEven ? 0.0 : 0.2;
          for (var v = -0.8 + sfasa; v <= 0.81; v += 0.4) {
            final c = q(u, v);
            canvas.drawCircle(c, pxLargo * 0.06, ciuffo);
            canvas.drawCircle(c, pxLargo * 0.022, centro);
          }
          riga++;
        }
    }
  }

  /// Le piante grasse al sole forte si tingono di rosso-bruno.
  void _arrossa(
    Canvas canvas,
    Offset Function(double, double) q,
    double pxLargo,
  ) {
    final rosso = m.bruciata * 0.55;
    if (rosso < 0.02) return;
    canvas.drawLine(
      q(0, 0),
      q(1, 0),
      Paint()
        ..color = const Color(0xFFA0503A).withValues(alpha: rosso)
        ..strokeWidth = pxLargo * 2.4,
    );
  }
}
