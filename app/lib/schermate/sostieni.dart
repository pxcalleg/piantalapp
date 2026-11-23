import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dati/donazioni.dart';

// Pagina del repository con gli altri modi per aiutare il progetto: si
// aggiorna senza bisogno di una nuova versione dell'app.
const _paginaSostegno =
    'https://github.com/pxcalleg/piantalapp/blob/main/SOSTIENI.md';

// Nome utente Ko-fi per le donazioni dalla versione web. Nell'app Android
// si dona solo con Google Play.
const utenteKofi = 'piantalapp';

const titoloSostieni = 'Sostieni lo sviluppo di PiantalAPP';

/// Il rosso del cuore, nella barra in alto e nella pagina delle donazioni.
const coloreCuore = Color(0xFFE53950);

/// Cosa "compra" ogni donazione, per renderla più concreta.
const _simboli = {
  'donazione_1': ('☕', 'Un caffè'),
  'donazione_2': ('🪴', 'Un vaso nuovo'),
  'donazione_3': ('🌳', 'Un albero'),
};

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const _Copertina(),
              const SizedBox(height: 24),
              ListenableBuilder(
                listenable: donazioni,
                builder: (context, _) => _donazioni(context, tema),
              ),
              const SizedBox(height: 28),
              _AltriModi(tema: tema),
            ],
          ),
        ),
      ),
    );
  }

  Widget _donazioni(BuildContext context, ThemeData tema) {
    switch (donazioni.stato) {
      case StatoDonazioni.caricamento:
        return const Center(child: CircularProgressIndicator());
      case StatoDonazioni.nonDisponibili:
        if (kIsWeb && utenteKofi.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PulsanteCuore(
                testo: 'Offrici un caffè su Ko-fi',
                onPressed: () => launchUrl(
                  Uri.parse('https://ko-fi.com/$utenteKofi'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scegli tu l\'importo. Il pagamento avviene in modo sicuro su '
                'Ko-fi, con carta o PayPal.',
                style: tema.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
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
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Grazie di cuore per il tuo sostegno!',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: coloreCuore,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, offerta) in donazioni.offerte.indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _Offerta(
                      offerta: offerta,
                      onTap: () => donazioni.dona(offerta),
                    ),
                  ),
                ],
              ],
            ),
            if (donazioni.errore != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  donazioni.errore!,
                  style: TextStyle(color: tema.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
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

/// Riquadro in alto: grande cuore rosso, titolo e due righe sul perché.
class _Copertina extends StatelessWidget {
  const _Copertina();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colori = tema.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              coloreCuore.withValues(alpha: 0.16),
              colori.surface,
            ),
            colori.primaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colori.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: coloreCuore.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 56,
                color: coloreCuore,
                semanticLabel: 'Cuore',
              ),
            ),
            const SizedBox(height: 18),
            Text(
              titoloSostieni,
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'PiantalAPP è gratuita, senza pubblicità e open source, e resterà '
              'così. Se ti è utile, una piccola donazione aiuta a coprire i '
              'costi e il tempo per aggiungere nuove piante e migliorare l\'app.',
              style: tema.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Una donazione di Google Play come riquadro da toccare.
class _Offerta extends StatelessWidget {
  const _Offerta({required this.offerta, required this.onTap});

  final ProductDetails offerta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final (simbolo, descrizione) = _simboli[offerta.id] ?? ('💚', 'Grazie!');
    return Semantics(
      button: true,
      label: 'Dona ${offerta.price}, $descrizione',
      excludeSemantics: true,
      child: Material(
        color: tema.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: coloreCuore.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
            child: Column(
              children: [
                Text(simbolo, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(
                  descrizione,
                  style: tema.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: coloreCuore,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Dona ${offerta.price}',
                    style: tema.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsante grande, rosso, con il cuore.
class _PulsanteCuore extends StatelessWidget {
  const _PulsanteCuore({required this.testo, required this.onPressed});

  final String testo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      backgroundColor: coloreCuore,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(56),
      textStyle: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    ),
    icon: const Icon(Icons.favorite),
    label: Text(testo),
    onPressed: onPressed,
  );
}

/// Come aiutare senza spendere nulla.
class _AltriModi extends StatelessWidget {
  const _AltriModi({required this.tema});

  final ThemeData tema;

  @override
  Widget build(BuildContext context) {
    Widget voce(IconData icona, String testo) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icona, size: 22, color: tema.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(testo)),
        ],
      ),
    );
    return Card(
      elevation: 0,
      color: tema.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puoi aiutare anche senza spendere nulla',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            voce(Icons.edit_note, 'Scrivi o correggi la scheda di una pianta'),
            voce(Icons.flag_outlined, 'Segnalaci un errore'),
            voce(Icons.share_outlined, 'Consiglia l\'app a chi ama le piante'),
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
      ),
    );
  }
}
