import 'package:flutter/material.dart';

import '../modello/pianta.dart';
import '../visuale/modelli.dart';
import '../visuale/motore_3d.dart';
import '../visuale/stato_pianta.dart';
import 'foto.dart';
import 'simulatore.dart';

enum _Vista { foto, pianta3d }

/// Riquadro in testa alla scheda: la foto reale oppure la pianta 3D che gira
/// lentamente, con il pulsante per aprire il simulatore.
class Vetrina extends StatefulWidget {
  const Vetrina({super.key, required this.pianta});

  final Pianta pianta;

  @override
  State<Vetrina> createState() => _VetrinaState();
}

class _VetrinaState extends State<Vetrina> with SingleTickerProviderStateMixin {
  late final AnimationController _giro = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );
  late _Vista _vista = widget.pianta.immagini.isEmpty
      ? _Vista.pianta3d
      : _Vista.foto;

  Specie? get _specie => modelliVisuali[widget.pianta.id];

  @override
  void initState() {
    super.initState();
    _aggiornaGiro();
  }

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  void _aggiornaGiro() {
    if (_vista == _Vista.pianta3d && _specie != null) {
      _giro.repeat();
    } else {
      _giro.stop();
    }
  }

  void _apriSimulatore() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => Simulatore(pianta: widget.pianta)));

  @override
  Widget build(BuildContext context) {
    final p = widget.pianta;
    final specie = _specie;
    final foto = p.immagini.firstOrNull;
    final colori = Theme.of(context).colorScheme;
    final mostra3d = _vista == _Vista.pianta3d && specie != null;

    final riquadro = AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colori.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: mostra3d
                ? GestureDetector(
                    key: const ValueKey('3d'),
                    onTap: _apriSimulatore,
                    child: AnimatedBuilder(
                      animation: _giro,
                      builder: (context, _) => CustomPaint(
                        painter: PiantaPainter(
                          specie: specie,
                          stato: const StatoPianta(),
                          rotazione: 0.5 + _giro.value * 2 * 3.141592653589793,
                          luce: 0.6,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  )
                : SizedBox.expand(
                    key: const ValueKey('foto'),
                    child: FotoPianta(pianta: p),
                  ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sui telefoni il riquadro non deve occupare tutto lo schermo.
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 460),
          child: Center(child: riquadro),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (foto != null && specie != null)
              SegmentedButton<_Vista>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: _Vista.foto,
                    icon: Icon(Icons.photo_outlined, size: 18),
                    label: Text('Foto'),
                  ),
                  ButtonSegment(
                    value: _Vista.pianta3d,
                    icon: Icon(Icons.view_in_ar_outlined, size: 18),
                    label: Text('3D'),
                  ),
                ],
                selected: {_vista},
                onSelectionChanged: (s) {
                  setState(() => _vista = s.first);
                  _aggiornaGiro();
                },
              ),
            if (specie != null)
              FilledButton.tonalIcon(
                onPressed: _apriSimulatore,
                icon: const Icon(Icons.threesixty),
                label: const Text('Ruota e simula'),
              ),
          ],
        ),
        if (foto != null && !mostra3d) CreditoFoto(immagine: foto),
      ],
    );
  }
}
