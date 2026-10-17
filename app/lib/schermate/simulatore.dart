import 'package:flutter/material.dart';

import '../modello/pianta.dart';
import '../visuale/modelli.dart';
import '../visuale/stato_pianta.dart';

/// Pianta interattiva: si ruota trascinando, si regola la luce e si
/// simulano situazioni di salute e malattia.
class Simulatore extends StatefulWidget {
  const Simulatore({super.key, required this.pianta});

  final Pianta pianta;

  @override
  State<Simulatore> createState() => _SimulatoreState();
}

class _SimulatoreState extends State<Simulatore> with TickerProviderStateMixin {
  late final AnimationController _giro = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();
  late final AnimationController _transizione = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..value = 1;

  double _rotazioneManuale = 0.5;
  bool _giraDaSola = true;
  double _luce = Scenario.sana.luce;
  Scenario? _scenario = Scenario.sana;
  StatoPianta _da = Scenario.sana.stato;
  StatoPianta _a = Scenario.sana.stato;

  StatoPianta get _stato =>
      StatoPianta.lerp(_da, _a, Curves.easeInOut.transform(_transizione.value));

  @override
  void dispose() {
    _giro.dispose();
    _transizione.dispose();
    super.dispose();
  }

  void _vaiA(StatoPianta nuovo, {bool anima = true}) {
    setState(() {
      _da = _stato;
      _a = nuovo;
    });
    if (anima) {
      _transizione.forward(from: 0);
    } else {
      _transizione.value = 1;
    }
  }

  void _scegli(Scenario s) {
    _scenario = s;
    _luce = s.luce;
    _vaiA(s.stato);
  }

  void _regola(StatoPianta Function(StatoPianta) modifica) {
    _scenario = null;
    _vaiA(modifica(_a), anima: false);
  }

  void _fermaGiro() {
    if (!_giraDaSola) return;
    setState(() {
      _rotazioneManuale += _giro.value * 2 * 3.141592653589793;
      _giraDaSola = false;
    });
    _giro.stop();
  }

  void _alternaGiro() {
    if (_giraDaSola) {
      _fermaGiro();
    } else {
      setState(() {
        _giraDaSola = true;
        _rotazioneManuale -= _giro.value * 2 * 3.141592653589793;
      });
      _giro.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pittore = modelliVisuali[widget.pianta.id]!;
    final tema = Theme.of(context);
    final scenario = _scenario;
    return Scaffold(
      appBar: AppBar(title: Text(widget.pianta.nome)),
      body: LayoutBuilder(
        builder: (context, vincoli) {
          final largo = vincoli.maxWidth > 800;
          final scena = _scena(pittore);
          final comandi = _comandi(tema, scenario);
          if (largo) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: scena,
                  ),
                ),
                Expanded(flex: 2, child: comandi),
              ],
            );
          }
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: scena,
              ),
              comandi,
            ],
          );
        },
      ),
    );
  }

  Widget _scena(CostruttorePittore pittore) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GestureDetector(
              onHorizontalDragStart: (_) => _fermaGiro(),
              onHorizontalDragUpdate: (d) =>
                  setState(() => _rotazioneManuale += d.delta.dx * 0.012),
              child: AnimatedBuilder(
                animation: Listenable.merge([_giro, _transizione]),
                builder: (context, _) => CustomPaint(
                  key: const Key('scena-pianta'),
                  painter: pittore(
                    _stato,
                    _rotazioneManuale +
                        (_giraDaSola ? _giro.value * 2 * 3.141592653589793 : 0),
                    _luce,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              tooltip: _giraDaSola
                  ? 'Ferma la rotazione'
                  : 'Fai girare la pianta',
              icon: Icon(
                _giraDaSola ? Icons.pause_circle_outline : Icons.threesixty,
              ),
              onPressed: _alternaGiro,
            ),
            const Expanded(child: Text('Trascina la pianta per ruotarla')),
          ],
        ),
      ],
    );
  }

  Widget _comandi(ThemeData tema, Scenario? scenario) {
    final s = _a;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Luce', style: tema.textTheme.titleMedium),
          Row(
            children: [
              const Icon(Icons.nights_stay_outlined),
              Expanded(
                child: Slider(
                  value: _luce,
                  label: _descriviLuce(_luce),
                  divisions: 20,
                  onChanged: (v) => setState(() => _luce = v),
                ),
              ),
              const Icon(Icons.wb_sunny),
            ],
          ),
          Text(_descriviLuce(_luce), style: tema.textTheme.bodySmall),
          const SizedBox(height: 16),
          Text('Situazioni', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final sc in Scenario.values)
                ChoiceChip(
                  label: Text(sc.etichetta),
                  selected: scenario == sc,
                  onSelected: (_) => _scegli(sc),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario?.etichetta ?? 'Situazione personalizzata',
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  if (scenario != null) ...[
                    Text('Cosa vedi: ${scenario.cosaVedi}'),
                    const SizedBox(height: 4),
                    Text('Cosa fare: ${scenario.cosaFare}'),
                  ] else
                    const Text('Hai regolato i sintomi a mano.'),
                ],
              ),
            ),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Regola i sintomi a mano'),
            children: [
              _cursore(
                'Vigore e crescita',
                s.vigore,
                (v) => _regola((x) => x.copyWith(vigore: v)),
              ),
              _cursore(
                'Umidità del terriccio',
                s.umiditaTerreno,
                (v) => _regola((x) => x.copyWith(umiditaTerreno: v)),
              ),
              _cursore(
                'Foglie gialle',
                s.ingiallimento,
                (v) => _regola((x) => x.copyWith(ingiallimento: v)),
              ),
              _cursore(
                'Foglie secche',
                s.secchezza,
                (v) => _regola((x) => x.copyWith(secchezza: v)),
              ),
              _cursore(
                'Foglie marce',
                s.marciume,
                (v) => _regola((x) => x.copyWith(marciume: v)),
              ),
              _cursore(
                'Foglie spente',
                s.spente,
                (v) => _regola((x) => x.copyWith(spente: v)),
              ),
              _cursore(
                'Foglie cadenti',
                s.appassimento,
                (v) => _regola((x) => x.copyWith(appassimento: v)),
              ),
              _cursore(
                'Foglie cadute',
                s.caduta,
                (v) => _regola((x) => x.copyWith(caduta: v)),
              ),
              _cursore(
                'Bruciature da sole',
                s.bruciature,
                (v) => _regola((x) => x.copyWith(bruciature: v)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Illustrazione generata dall\'app: mostra l\'aspetto tipico della pianta, '
            'non una foto.',
            style: tema.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _cursore(String nome, double valore, ValueChanged<double> cambia) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(nome)),
        Expanded(
          child: Slider(value: valore, onChanged: cambia),
        ),
      ],
    );
  }

  static String _descriviLuce(double l) => switch (l) {
    < 0.25 => 'Poca luce: stanza buia o lontano dalle finestre',
    < 0.5 => 'Luce media: a qualche metro da una finestra',
    < 0.8 => 'Molta luce indiretta: vicino a una finestra luminosa',
    _ => 'Sole diretto',
  };
}
