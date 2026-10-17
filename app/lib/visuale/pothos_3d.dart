import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'stato_pianta.dart';

/// Pothos in vaso disegnato in tempo reale a partire da una geometria 3D
/// generata (nessuna immagine esterna). Il vaso ha raggio 1 al bordo, che sta
/// all'altezza y = 0; y cresce verso l'alto.
class PothosPainter extends CustomPainter {
  PothosPainter({
    required this.stato,
    required this.rotazione,
    required this.luce,
  });

  final StatoPianta stato;

  /// Angolo di rotazione attorno all'asse verticale, in radianti.
  final double rotazione;

  /// Luce della stanza, da 0 (buio) a 1 (sole pieno).
  final double luce;

  static const _inclinazione = 0.38;
  static const _altezzaVaso = 1.45;
  static const _raggioFondo = 0.74;
  static final _fusti = _generaFusti();

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _Camera(size, rotazione, _inclinazione);
    _disegnaStanza(canvas, size, cam);

    final dietro = <_Elemento>[];
    final davanti = <_Elemento>[];
    void aggiungi(_Elemento e) => (e.nascosto ? dietro : davanti).add(e);

    for (final f in _fusti) {
      _costruisciFusto(f, cam, aggiungi);
    }

    dietro.sort((a, b) => a.profondita.compareTo(b.profondita));
    davanti.sort((a, b) => a.profondita.compareTo(b.profondita));
    for (final e in dietro) {
      e.disegna(canvas);
    }
    _disegnaVaso(canvas, cam);
    for (final e in davanti) {
      e.disegna(canvas);
    }
  }

  @override
  bool shouldRepaint(PothosPainter old) =>
      old.stato != stato || old.rotazione != rotazione || old.luce != luce;

  // ---------------------------------------------------------------- stanza

  double get _luceScena => 0.45 + 0.65 * luce;

  void _disegnaStanza(Canvas canvas, Size size, _Camera cam) {
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
    final piano = cam.proietta(const _V3(0, -_altezzaVaso, 0)).dy;
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
    final centroOmbra = cam.proietta(const _V3(0.35, -_altezzaVaso, -0.2));
    canvas.drawOval(
      Rect.fromCenter(
        center: centroOmbra,
        width: cam.unita * 2.6,
        height: cam.unita * 2.6 * math.sin(_inclinazione) * 0.9,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12 + 0.25 * luce)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.unita * 0.12),
    );
  }

  // ------------------------------------------------------------------- vaso

  void _disegnaVaso(Canvas canvas, _Camera cam) {
    final u = cam.unita;
    final schiaccia = math.sin(_inclinazione);
    final centroAlto = cam.proietta(const _V3(0, 0, 0));
    final centroBasso = cam.proietta(const _V3(0, -_altezzaVaso, 0));
    final sAlto = cam.scala(const _V3(0, 0, 0));
    final sBasso = cam.scala(const _V3(0, -_altezzaVaso, 0));
    final rA = u * sAlto;
    final rB = u * _raggioFondo * sBasso;

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
    final terracotta = _illumina(const Color(0xFFB4643A), 1);
    canvas.drawPath(
      corpo,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _schiarisci(terracotta, 0.18),
            terracotta,
            _scurisci(terracotta, 0.45),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(corpo.getBounds()),
    );

    // Terriccio, appena sotto il bordo.
    final centroTerra = cam.proietta(const _V3(0, -0.07, 0));
    final rT = rA * 0.95;
    final ovaleTerra = Rect.fromCenter(
      center: centroTerra,
      width: rT * 2,
      height: rT * 2 * schiaccia,
    );
    final umido = stato.umiditaTerreno;
    final terra = _illumina(
      Color.lerp(const Color(0xFFA88462), const Color(0xFF33251B), umido)!,
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
        ..color = _schiarisci(terracotta, 0.08),
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

  // ------------------------------------------------------------ fusti/foglie

  void _costruisciFusto(
    _Fusto f,
    _Camera cam,
    void Function(_Elemento) aggiungi,
  ) {
    final s = stato;
    final w = s.appassimento;
    final vigore = s.vigore;
    // Poca vigoria = fusti lunghi e spogli (pianta filata).
    final lunghezza = f.lunghezza * (0.85 + 0.35 * (1 - vigore));
    final altezza = f.altezza * (1 - 0.55 * w);
    final caduta = f.ricadente ? f.ricaduta * (1 + 0.6 * w) : 0.15 * w;

    _V3 punto(double t) {
      final r = f.r0 + lunghezza * t;
      var y =
          altezza * math.sin(math.pi * math.min(t * 1.15, 1)) - caduta * t * t;
      // Il fusto non può attraversare il vaso.
      if (r < 1.08) y = math.max(y, -0.04);
      // Oltre il bordo i fusti lunghi si appoggiano sul piano.
      y = math.max(y, -_altezzaVaso + 0.03);
      final a = f.angolo + f.torsione * t;
      return _V3(r * math.cos(a), y, r * math.sin(a));
    }

    const passi = 18;
    final punti = [for (var i = 0; i <= passi; i++) punto(i / passi)];
    final spessore = cam.unita * 0.035 * (0.7 + 0.3 * vigore);
    for (var i = 0; i < passi; i++) {
      final a = punti[i], b = punti[i + 1];
      final t = i / passi;
      final marcio = (s.marciume * 1.3 - t * 2).clamp(0.0, 1.0);
      final colore = Color.lerp(
        Color.lerp(
          const Color(0xFF6E8F3E),
          const Color(0xFF8A8A5C),
          s.spente * 0.6,
        )!,
        const Color(0xFF2B1D12),
        marcio,
      )!;
      aggiungi(
        _Segmento(
          cam.proietta(a),
          cam.proietta(b),
          _illumina(colore, 0.9),
          spessore * (1 - 0.35 * t) * (cam.scala(a) + cam.scala(b)) / 2,
          cam.profondita(a.medio(b)),
          _dietroAlVaso(a.medio(b), cam),
        ),
      );
    }

    final numeroFoglie = (f.foglie * (0.45 + 0.75 * vigore)).round();
    for (var k = 0; k < numeroFoglie; k++) {
      final rnd = math.Random(f.seme * 100 + k);
      final t = 0.1 + (k + 0.5) / numeroFoglie * 0.9;
      final base = punto(t);
      final avanti = punto(math.min(t + 0.03, 1));
      final tangente = (avanti - base).normalizzato();
      final radiale = _V3(base.x, 0, base.z).normalizzato();
      final lato = _V3(-radiale.z, 0, radiale.x) * (k.isEven ? 1.0 : -1.0);
      final su = 0.55 - 1.5 * w + (rnd.nextDouble() - 0.5) * 0.3;
      final dir =
          (radiale * 0.5 +
                  lato * (0.55 + rnd.nextDouble() * 0.3) +
                  const _V3(0, 1, 0) * su +
                  tangente * 0.25)
              .normalizzato();
      final nuova = t > 0.86 && vigore > 0.55;
      final dimensione =
          (0.24 + 0.24 * vigore) *
          (0.75 + 0.5 * rnd.nextDouble()) *
          (nuova ? 0.7 : 1) *
          (1 - 0.25 * s.secchezza);
      final picciolo = base + dir * 0.1;

      // Le foglie più vecchie (vicino alla base) si ammalano per prime.
      final u1 = rnd.nextDouble(), u2 = rnd.nextDouble(), u3 = rnd.nextDouble();
      final priorita = 0.45 * u1 + 0.55 * t;
      double quota(double livello, double p) =>
          ((livello * 1.15 - p) / 0.18).clamp(0.0, 1.0);

      if (quota(s.caduta, priorita) > 0.5) {
        _fogliaCaduta(f, k, rnd, cam, aggiungi, dimensione);
        continue;
      }
      final foglia = _Foglia(
        picciolo: base,
        base: picciolo,
        punta: picciolo + dir * dimensione,
        dimensione: dimensione,
        gialla: quota(s.ingiallimento, priorita),
        secca: quota(s.secchezza, 0.5 * u2 + 0.5 * t),
        marcia: quota(s.marciume, 0.3 * u1 + 0.7 * t),
        bruciata: quota(s.bruciature, 0.4 * u3 + 0.6 * (1 - t)),
        nuova: nuova,
        variegatura: u2,
        seme: f.seme * 100 + k,
      );
      aggiungi(_ElementoFoglia(foglia, this, cam));
    }
  }

  void _fogliaCaduta(
    _Fusto f,
    int k,
    math.Random rnd,
    _Camera cam,
    void Function(_Elemento) aggiungi,
    double dimensione,
  ) {
    final a = f.angolo + rnd.nextDouble() * 1.2;
    final r = 1.0 + rnd.nextDouble() * 0.7;
    final base = _V3(r * math.cos(a), -_altezzaVaso + 0.01, r * math.sin(a));
    final dirA = a + rnd.nextDouble() * math.pi * 2;
    final dir = _V3(math.cos(dirA), 0.08, math.sin(dirA));
    aggiungi(
      _ElementoFoglia(
        _Foglia(
          picciolo: base,
          base: base,
          punta: base + dir * dimensione,
          dimensione: dimensione,
          gialla: 0.9,
          secca: 0.4 + 0.5 * rnd.nextDouble(),
          marcia: stato.marciume * 0.6,
          bruciata: 0,
          nuova: false,
          variegatura: 0,
          seme: f.seme * 100 + k,
          aTerra: true,
        ),
        this,
        cam,
      ),
    );
  }

  bool _dietroAlVaso(_V3 p, _Camera cam) {
    if (p.y > -0.04) return false;
    return cam.profondita(p) < 0;
  }

  // ----------------------------------------------------------------- colori

  Color _illumina(Color c, double intensita) {
    final l = _luceScena * intensita;
    return l <= 1
        ? Color.lerp(Colors.black, c, l)!
        : Color.lerp(c, Colors.white, (l - 1) * 0.35)!;
  }

  static Color _schiarisci(Color c, double q) =>
      Color.lerp(c, Colors.white, q)!;
  static Color _scurisci(Color c, double q) => Color.lerp(c, Colors.black, q)!;

  Color _coloreFoglia(_Foglia f, double luceDiretta) {
    var c = f.nuova ? const Color(0xFF7DBE4E) : const Color(0xFF3F8A34);
    c = Color.lerp(c, const Color(0xFFD9C24A), f.gialla)!;
    c = Color.lerp(c, const Color(0xFF8A8F70), stato.spente * 0.65)!;
    c = Color.lerp(
      c,
      const Color(0xFF9B7045),
      ((f.secca - 0.45) / 0.55).clamp(0.0, 1.0),
    )!;
    c = Color.lerp(c, const Color(0xFF2E2116), f.marcia * 0.85)!;
    return _illumina(c, 0.6 + 0.55 * luceDiretta);
  }

  /// Quanta variegatura gialla resta visibile: sparisce con poca luce.
  double _variegatura(_Foglia f) =>
      ((luce - 0.2) / 0.35).clamp(0.0, 1.0) *
      (1 - stato.spente) *
      (1 - f.marcia) *
      (1 - f.gialla * 0.7) *
      (0.35 + 0.65 * f.variegatura);
}

// ------------------------------------------------------------------ geometria

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

class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) =>
      _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get lunghezza => math.sqrt(dot(this));
  _V3 normalizzato() {
    final l = lunghezza;
    return l < 1e-9 ? const _V3(0, 1, 0) : this * (1 / l);
  }

  _V3 medio(_V3 o) => (this + o) * 0.5;
}

class _Camera {
  _Camera(Size size, double rotazione, double inclinazione)
    : _cosR = math.cos(rotazione),
      _sinR = math.sin(rotazione),
      _cosI = math.cos(inclinazione),
      _sinI = math.sin(inclinazione),
      unita = math.min(size.width / 4.6, size.height / 4.9),
      centro = Offset(size.width / 2, size.height * 0.43);

  final double _cosR, _sinR, _cosI, _sinI;
  final double unita;
  final Offset centro;
  static const _fuoco = 7.0;

  /// Luce in coordinate di camera: dall'alto a sinistra, dalla finestra.
  static final direzioneLuce = const _V3(-0.55, 0.75, 0.45).normalizzato();

  _V3 vista(_V3 p) {
    final x = p.x * _cosR + p.z * _sinR;
    final z = -p.x * _sinR + p.z * _cosR;
    return _V3(x, p.y * _cosI - z * _sinI, p.y * _sinI + z * _cosI);
  }

  /// Ruota un vettore direzione (senza prospettiva).
  _V3 ruota(_V3 d) => vista(d);

  double scala(_V3 p) => _fuoco / (_fuoco - vista(p).z);
  double profondita(_V3 p) => vista(p).z;

  Offset proietta(_V3 p) {
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

class _Foglia {
  const _Foglia({
    required this.picciolo,
    required this.base,
    required this.punta,
    required this.dimensione,
    required this.gialla,
    required this.secca,
    required this.marcia,
    required this.bruciata,
    required this.nuova,
    required this.variegatura,
    required this.seme,
    this.aTerra = false,
  });

  final _V3 picciolo, base, punta;
  final double dimensione, gialla, secca, marcia, bruciata, variegatura;
  final bool nuova, aTerra;
  final int seme;
}

class _ElementoFoglia implements _Elemento {
  _ElementoFoglia(this.f, this.pittore, this.cam)
    : profondita = cam.profondita(f.base.medio(f.punta)),
      nascosto = f.aTerra
          ? cam.profondita(f.base) < -0.2
          : pittore._dietroAlVaso(f.base.medio(f.punta), cam);

  final _Foglia f;
  final PothosPainter pittore;
  final _Camera cam;
  @override
  final double profondita;
  @override
  final bool nascosto;

  @override
  void disegna(Canvas canvas) {
    final dir = (f.punta - f.base).normalizzato();
    var lato = const _V3(0, 1, 0).cross(dir);
    if (lato.lunghezza < 0.2) lato = const _V3(1, 0, 0);
    lato = lato.normalizzato();
    final normale = lato.cross(dir).normalizzato();
    final nVista = cam.ruota(normale);
    final frontale = nVista.z.abs();
    final luceDiretta = math.max(
      0.0,
      nVista.dot(_Camera.direzioneLuce) * (nVista.z < 0 ? 0.5 : 1),
    );

    final p0 = cam.proietta(f.picciolo);
    final b = cam.proietta(f.base);
    final t = cam.proietta(f.punta);
    var asse = t - b;
    final lungo = f.dimensione * cam.unita * cam.scala(f.base);
    if (asse.distance < lungo * 0.3) {
      // Foglia vista di punta: le diamo comunque un minimo di lunghezza.
      final d = asse.distance < 1e-6
          ? const Offset(0, -1)
          : asse / asse.distance;
      asse = d * lungo * 0.3;
    }
    final perp = Offset(-asse.dy, asse.dx) / asse.distance;
    // Le foglie secche o mosce si accartocciano e si restringono.
    final arriccia = 1 - 0.45 * f.secca - 0.25 * pittore.stato.appassimento;
    final larghezza = lungo * 0.9 * (0.45 + 0.55 * frontale) * arriccia;

    Offset q(double u, double v) => b + asse * u + perp * (larghezza * v);
    final path = Path()
      ..moveTo(b.dx, b.dy)
      ..cubicTo(
        q(-0.14, 0.28).dx,
        q(-0.14, 0.28).dy,
        q(0.02, 0.62).dx,
        q(0.02, 0.62).dy,
        q(0.33, 0.56).dx,
        q(0.33, 0.56).dy,
      )
      ..cubicTo(
        q(0.62, 0.5).dx,
        q(0.62, 0.5).dy,
        q(0.9, 0.18).dx,
        q(0.9, 0.18).dy,
        q(1, 0).dx,
        q(1, 0).dy,
      )
      ..cubicTo(
        q(0.9, -0.18).dx,
        q(0.9, -0.18).dy,
        q(0.62, -0.5).dx,
        q(0.62, -0.5).dy,
        q(0.33, -0.56).dx,
        q(0.33, -0.56).dy,
      )
      ..cubicTo(
        q(0.02, -0.62).dx,
        q(0.02, -0.62).dy,
        q(-0.14, -0.28).dx,
        q(-0.14, -0.28).dy,
        b.dx,
        b.dy,
      )
      ..close();

    // Picciolo.
    canvas.drawLine(
      p0,
      b,
      Paint()
        ..color = pittore._coloreFoglia(f, luceDiretta * 0.6)
        ..strokeWidth = lungo * 0.05
        ..strokeCap = StrokeCap.round,
    );

    final colore = pittore._coloreFoglia(f, luceDiretta);
    canvas.drawPath(path, Paint()..color = colore);

    canvas.save();
    canvas.clipPath(path);
    final rnd = math.Random(f.seme);

    // Variegatura dorata tipica del pothos.
    final varieg = pittore._variegatura(f);
    if (varieg > 0.02) {
      final pv = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = larghezza * 0.07
        ..color = const Color(0xFFF1E59A).withValues(alpha: 0.55 * varieg);
      for (var i = 0; i < 4; i++) {
        final v0 = (rnd.nextDouble() - 0.5) * 0.7;
        final v1 = v0 + (rnd.nextDouble() - 0.5) * 0.5;
        final s = Path()
          ..moveTo(q(0.05, v0 * 0.3).dx, q(0.05, v0 * 0.3).dy)
          ..quadraticBezierTo(
            q(0.45, v0).dx,
            q(0.45, v0).dy,
            q(0.85, v1 * 0.4).dx,
            q(0.85, v1 * 0.4).dy,
          );
        canvas.drawPath(s, pv);
      }
    }

    // Bruciature da sole: chiazze chiare al centro.
    if (f.bruciata > 0.02) {
      for (var i = 0; i < 2; i++) {
        final c = q(
          0.35 + rnd.nextDouble() * 0.4,
          (rnd.nextDouble() - 0.5) * 0.6,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: c,
            width: larghezza * 0.6,
            height: larghezza * 0.45,
          ),
          Paint()
            ..color = const Color(0xFFE2D3A6)
                .withValues(alpha: 0.85 * f.bruciata)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, larghezza * 0.06),
        );
      }
    }

    // Marciume: chiazza scura che parte dalla base.
    if (f.marcia > 0.02) {
      canvas.drawCircle(
        b,
        lungo * (0.2 + 0.6 * f.marcia),
        Paint()
          ..color = const Color(0xFF1F150D).withValues(alpha: 0.7 * f.marcia)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, lungo * 0.12),
      );
    }

    // Nervatura centrale.
    canvas.drawLine(
      b,
      b + asse * 0.92,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = lungo * 0.025,
    );
    canvas.restore();

    // Bordi secchi.
    if (f.secca > 0.02) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lungo * 0.08 * f.secca
          ..color = pittore._illumina(const Color(0xFF7A5230), 0.9),
      );
    }
    // Lucentezza delle foglie sane.
    final lucido = (1 - f.secca) * (1 - pittore.stato.spente) * (1 - f.marcia);
    if (lucido > 0.3 && frontale > 0.4) {
      canvas.drawLine(
        q(0.25, 0.25),
        q(0.6, 0.2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18 * lucido * pittore.luce)
          ..strokeWidth = larghezza * 0.08
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
