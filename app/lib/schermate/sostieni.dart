import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dati/donazioni.dart';

// Pagina del repository con gli altri modi per aiutare il progetto: si
// aggiorna senza bisogno di una nuova versione dell'app.
const _paginaSostegno =
    'https://github.com/pxcalleg/piantalapp/blob/main/SOSTIENI.md';

// Nome utente Ko-fi per le donazioni dalla versione web; vuoto finché
// l'account non esiste. Nell'app Android si dona solo con Google Play.
const utenteKofi = '';

const titoloSostieni = 'Sostieni lo sviluppo di PiantalAPP';

class Sostieni extends StatelessWidget {
  Sostieni({super.key, Donazioni? donazioni})
    : donazioni = donazioni ?? _predefinite();

  final Donazioni donazioni;

  static Donazioni _predefinite() => donazioniApp..avvia();

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
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: donazioni,
            builder: (context, _) => _donazioni(tema),
          ),
          const SizedBox(height: 24),
          const Text(
            'Puoi aiutare anche senza spendere nulla: scrivendo o correggendo '
            'una scheda, segnalando un errore o consigliando l\'app a chi ama '
            'le piante.',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => launchUrl(
                Uri.parse(_paginaSostegno),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Altri modi per aiutare'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _donazioni(ThemeData tema) {
    switch (donazioni.stato) {
      case StatoDonazioni.caricamento:
        return const Center(child: CircularProgressIndicator());
      case StatoDonazioni.nonDisponibili:
        if (kIsWeb && utenteKofi.isNotEmpty) {
          return FilledButton.icon(
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Dona con Ko-fi'),
            onPressed: () => launchUrl(
              Uri.parse('https://ko-fi.com/$utenteKofi'),
              mode: LaunchMode.externalApplication,
            ),
          );
        }
        return Text(
          'Le donazioni si fanno dall\'app scaricata dal Google Play Store.',
          style: tema.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case StatoDonazioni.pronte:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (donazioni.grazie)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Grazie di cuore per il tuo sostegno!',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: tema.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final offerta in donazioni.offerte)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.icon(
                  icon: const Icon(Icons.volunteer_activism),
                  label: Text('Dona ${offerta.price}'),
                  onPressed: () => donazioni.dona(offerta),
                ),
              ),
            if (donazioni.errore != null)
              Text(
                donazioni.errore!,
                style: TextStyle(color: tema.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            Text(
              'Il pagamento avviene in modo sicuro tramite Google Play.',
              style: tema.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }
}
