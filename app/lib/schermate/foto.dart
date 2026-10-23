import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modello/fungo.dart';
import '../modello/pianta.dart';

/// Foto reale della pianta: la copia inclusa nell'app, oppure quella online
/// se la scheda è arrivata con un aggiornamento e la foto non è ancora inclusa.
class FotoPianta extends StatelessWidget {
  const FotoPianta({super.key, required this.pianta, this.fit = BoxFit.cover});

  final Pianta pianta;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => _Foto(
    immagine: pianta.immagini.firstOrNull,
    descrizione: 'Foto di ${pianta.nome}',
    eroe: 'foto-${pianta.id}',
    fit: fit,
    icona: Icons.local_florist,
  );
}

/// Foto reale del fungo, con le stesse regole di [FotoPianta].
class FotoFungo extends StatelessWidget {
  const FotoFungo({super.key, required this.fungo, this.fit = BoxFit.cover});

  final Fungo fungo;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => _Foto(
    immagine: fungo.immagini.firstOrNull,
    descrizione: 'Foto di ${fungo.nome}',
    eroe: 'foto-fungo-${fungo.id}',
    fit: fit,
    icona: Icons.forest,
  );
}

class _Foto extends StatelessWidget {
  const _Foto({
    required this.immagine,
    required this.descrizione,
    required this.eroe,
    required this.fit,
    required this.icona,
  });

  final Immagine? immagine;
  final String descrizione;
  final String eroe;
  final BoxFit fit;
  final IconData icona;

  @override
  Widget build(BuildContext context) {
    final immagine = this.immagine;
    if (immagine == null) return _Segnaposto(icona);
    return Hero(
      tag: eroe,
      child: Image.asset(
        immagine.asset,
        fit: fit,
        semanticLabel: descrizione,
        errorBuilder: (context, _, _) => Image.network(
          immagine.anteprima,
          fit: fit,
          semanticLabel: descrizione,
          errorBuilder: (context, _, _) => _Segnaposto(icona),
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
  const _Segnaposto(this.icona);

  final IconData icona;

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colori.primaryContainer,
      child: Center(child: Icon(icona, color: colori.onPrimaryContainer)),
    );
  }
}
