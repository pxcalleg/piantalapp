import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _repository = 'https://github.com/pxcalleg/piantalapp';

class Info extends StatelessWidget {
  const Info({super.key});

  Future<void> _apri(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Informazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('PiantalAPP', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Schede di cura per piante e fiori scritte da una comunità di '
            'appassionati ed esperti. Le schede funzionano anche senza rete '
            'e si aggiornano da sole quando sei connesso.',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.volunteer_activism_outlined),
            title: const Text('Contribuisci con una scheda'),
            subtitle: const Text('Aggiungi o correggi una pianta su GitHub'),
            onTap: () => _apri('$_repository/blob/main/CONTRIBUTING.md'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Segnala un errore'),
            subtitle: const Text('Apri una segnalazione sul progetto'),
            onTap: () => _apri('$_repository/issues/new'),
          ),
          const Divider(height: 32),
          Text('Licenze', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Contenuti delle schede: CC BY-SA 4.0, © PiantalAPP e i suoi contributori.',
          ),
          const SizedBox(height: 4),
          const Text('Codice dell\'app: Apache 2.0.'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'PiantalAPP',
              ),
              child: const Text('Licenze delle librerie usate'),
            ),
          ),
        ],
      ),
    );
  }
}
