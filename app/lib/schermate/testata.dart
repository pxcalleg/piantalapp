import 'package:flutter/material.dart';

/// Logo e nome dell'app, in alto in ogni pagina. Toccandolo si torna
/// all'elenco delle piante.
class Testata extends StatelessWidget {
  const Testata({super.key, this.sottotitolo});

  /// Nome della pagina, scritto in piccolo sotto "PiantalAPP".
  final String? sottotitolo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final sottotitolo = this.sottotitolo;
    return Semantics(
      button: true,
      label: 'PiantalAPP, torna all\'elenco delle piante',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/logo.png', width: 32, height: 32),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('PiantalAPP'),
                    if (sottotitolo != null)
                      Text(
                        sottotitolo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
