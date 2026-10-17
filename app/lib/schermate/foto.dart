import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modello/pianta.dart';

/// Foto reale della pianta: la copia inclusa nell'app, oppure quella online
/// se la scheda è arrivata con un aggiornamento e la foto non è ancora inclusa.
class FotoPianta extends StatelessWidget {
  const FotoPianta({super.key, required this.pianta, this.fit = BoxFit.cover});

  final Pianta pianta;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final immagine = pianta.immagini.firstOrNull;
    if (immagine == null) return const _Segnaposto();
    return Hero(
      tag: 'foto-${pianta.id}',
      child: Image.asset(
        immagine.asset,
        fit: fit,
        semanticLabel: 'Foto di ${pianta.nome}',
        errorBuilder: (context, _, _) => Image.network(
          immagine.anteprima,
          fit: fit,
          semanticLabel: 'Foto di ${pianta.nome}',
          errorBuilder: (context, _, _) => const _Segnaposto(),
        ),
      ),
    );
  }
}

/// Riga con autore e licenza della foto, obbligatoria per le licenze CC.
class CreditoFoto extends StatelessWidget {
  const CreditoFoto({super.key, required this.immagine});

  final Immagine immagine;

  @override
  Widget build(BuildContext context) {
    final stile = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return InkWell(
      onTap: () => launchUrl(
        Uri.parse(immagine.pagina),
        mode: LaunchMode.externalApplication,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.photo_camera_outlined, size: 14, color: stile?.color),
            const SizedBox(width: 6),
            Expanded(child: Text(immagine.credito, style: stile)),
          ],
        ),
      ),
    );
  }
}

class _Segnaposto extends StatelessWidget {
  const _Segnaposto();

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colori.primaryContainer,
      child: Center(
        child: Icon(Icons.local_florist, color: colori.onPrimaryContainer),
      ),
    );
  }
}
