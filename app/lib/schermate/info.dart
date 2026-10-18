import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contattaci.dart';
import 'testata.dart';

const _repository = 'https://github.com/pxcalleg/piantalapp';

class Info extends StatelessWidget {
  const Info({super.key});

  Future<void> _apri(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Testata(sottotitolo: 'Informazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset('assets/logo.png', width: 56, height: 56),
              ),
              const SizedBox(width: 14),
              Text('PiantalAPP', style: tema.textTheme.headlineSmall),
            ],
          ),
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
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contattaci'),
            subtitle: const Text('Collabora, proponi una pianta o scrivici'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const Contattaci())),
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
          const SizedBox(height: 4),
          const Text(
            'Foto delle piante: da Wikimedia Commons, con autore e licenza '
            'indicati sotto ogni foto.',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CreditiFoto())),
              child: const Text('Crediti delle foto'),
            ),
          ),
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

/// Elenco di tutte le foto incluse nell'app, con titolo, autore, licenza e
/// link alla fonte, come chiedono le licenze Creative Commons.
class CreditiFoto extends StatelessWidget {
  const CreditiFoto({super.key});

  Future<List<_Credito>> _carica(BuildContext context) async {
    final bundle = DefaultAssetBundle.of(context);
    final crediti = jsonDecode(
      await bundle.loadString('assets/immagini/crediti.json'),
    ) as Map<String, dynamic>;
    final piante =
        // load invece di loadString: oltre i 50 KB loadString decodifica in
        // un isolate, che nei test dei widget non termina mai.
        (jsonDecode(
              utf8.decode(
                (await bundle.load('assets/piante.json')).buffer.asUint8List(),
              ),
            ) as Map<String, dynamic>)['piante']
            as List<dynamic>;
    final nomi = {
      for (final p in piante.cast<Map<String, dynamic>>())
        p['id'] as String: p['nome_scientifico'] as String,
    };
    return [
      for (final MapEntry(:key, :value) in crediti.entries)
        for (final c in (value as List<dynamic>).cast<Map<String, dynamic>>())
          _Credito(
            pianta: nomi[key] ?? key,
            titolo: c['commons'] as String,
            autore: c['autore'] as String,
            licenza: c['licenza'] as String,
            urlLicenza: c['url_licenza'] as String,
            pagina: c['pagina'] as String,
          ),
    ]..sort((a, b) => a.pianta.compareTo(b.pianta));
  }

  Future<void> _apri(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Testata(sottotitolo: 'Crediti delle foto')),
      body: FutureBuilder(
        future: _carica(context),
        builder: (context, snap) {
          final crediti = snap.data;
          if (crediti == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Le foto vengono da Wikimedia Commons e sono usate secondo la '
                'licenza scelta dai loro autori. Sono ridimensionate ma non '
                'modificate.',
              ),
              for (final c in crediti) ...[
                const Divider(height: 32),
                Text(
                  c.pianta,
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text('«${c.titolo}» di ${c.autore}'),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (c.urlLicenza.isEmpty)
                      Text(
                        c.licenza == 'Public domain'
                            ? 'Pubblico dominio'
                            : c.licenza,
                      )
                    else
                      TextButton(
                        onPressed: () => _apri(c.urlLicenza),
                        child: Text('Licenza ${c.licenza}'),
                      ),
                    TextButton(
                      onPressed: () => _apri(c.pagina),
                      child: const Text('Fonte su Wikimedia Commons'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Credito {
  const _Credito({
    required this.pianta,
    required this.titolo,
    required this.autore,
    required this.licenza,
    required this.urlLicenza,
    required this.pagina,
  });

  final String pianta;
  final String titolo;
  final String autore;
  final String licenza;
  final String urlLicenza;
  final String pagina;
}
