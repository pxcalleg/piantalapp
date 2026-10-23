import 'package:flutter/material.dart';

/// Titolo con icona e un elenco di voci, usato nelle schede di piante e funghi.
class SezioneScheda extends StatelessWidget {
  const SezioneScheda({
    super.key,
    required this.icona,
    required this.titolo,
    required this.voci,
  });

  final IconData icona;
  final String titolo;

  /// Coppie (etichetta, testo); un'etichetta vuota mostra solo il testo.
  final List<(String, String)> voci;

  @override
  Widget build(BuildContext context) {
    if (voci.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icona, color: tema.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(titolo, style: tema.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          for (final (nome, testo) in voci)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (nome.isNotEmpty)
                      TextSpan(
                        text: '$nome: ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    TextSpan(text: testo),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
