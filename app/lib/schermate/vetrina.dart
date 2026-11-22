import 'package:flutter/material.dart';

import '../modello/pianta.dart';
import 'foto.dart';

/// Riquadro in testa alla scheda con la foto della pianta e il suo credito.
class Vetrina extends StatelessWidget {
  const Vetrina({super.key, required this.pianta});

  final Pianta pianta;

  @override
  Widget build(BuildContext context) {
    final foto = pianta.immagini.firstOrNull;
    final colori = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sui telefoni il riquadro non deve occupare tutto lo schermo.
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 460),
          child: Center(
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colori.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox.expand(child: FotoPianta(pianta: pianta)),
                ),
              ),
            ),
          ),
        ),
        if (foto != null) CreditoFoto(immagine: foto),
      ],
    );
  }
}
