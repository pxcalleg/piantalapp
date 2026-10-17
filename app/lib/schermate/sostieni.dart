import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Con --dart-define=SOSTIENI=false il tasto sparisce, ad esempio per una
// build destinata a uno store che non ammette link a donazioni esterne.
const mostraSostieni = bool.fromEnvironment('SOSTIENI', defaultValue: true);

// Pagina del repository con i modi per sostenere il progetto: si aggiorna
// senza bisogno di una nuova versione dell'app.
const _paginaSostegno =
    'https://github.com/pxcalleg/piantalapp/blob/main/SOSTIENI.md';

const titoloSostieni = 'Sostieni lo sviluppo di PiantalAPP';

class Sostieni extends StatelessWidget {
  const Sostieni({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sostieni PiantalAPP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(Icons.favorite, size: 56, color: tema.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            titoloSostieni,
            style: tema.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'PiantalAPP è gratuita, senza pubblicità e open source, e resterà '
            'così. Se ti è utile, una piccola donazione aiuta a coprire i costi '
            'e il tempo per aggiungere nuove piante e migliorare l\'app.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Puoi aiutare anche senza spendere nulla: scrivendo o correggendo '
            'una scheda, segnalando un errore o consigliando l\'app a chi ama '
            'le piante.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Fai una donazione'),
            onPressed: () => launchUrl(
              Uri.parse(_paginaSostegno),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Si apre una pagina web con i modi per donare.',
            style: tema.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
