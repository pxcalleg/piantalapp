import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'testata.dart';

/// Indirizzo a cui arrivano i messaggi del modulo. Se resta vuoto i messaggi
/// vengono inviati come segnalazione su GitHub.
const indirizzoContatti = 'piantalapp@lcsoluzioni.it';

const _repository = 'https://github.com/pxcalleg/piantalapp';

/// Motivi tra cui scegliere nel modulo.
enum Motivo {
  collaborare('Vorrei collaborare al progetto', Icons.handshake_outlined),
  nuovaPianta(
    'Potete inserire una nuova pianta?',
    Icons.local_florist_outlined,
  ),
  errore('Ho trovato un errore in una scheda', Icons.report_outlined),
  idea('Ho un\'idea per migliorare l\'app', Icons.lightbulb_outline),
  sviluppatori('Scrivi agli sviluppatori', Icons.code),
  altro('Altro', Icons.chat_bubble_outline);

  const Motivo(this.etichetta, this.icona);

  final String etichetta;
  final IconData icona;
}

/// Prepara oggetto e testo del messaggio dai campi del modulo.
({String oggetto, String testo}) componiMessaggio({
  required Motivo motivo,
  required String messaggio,
  String nome = '',
  String pianta = '',
}) {
  final oggetto = switch (motivo) {
    Motivo.nuovaPianta when pianta.trim().isNotEmpty =>
      'Nuova pianta: ${pianta.trim()}',
    Motivo.errore when pianta.trim().isNotEmpty =>
      'Errore nella scheda: ${pianta.trim()}',
    _ => motivo.etichetta,
  };
  final righe = [
    'Motivo: ${motivo.etichetta}',
    if (pianta.trim().isNotEmpty) 'Pianta: ${pianta.trim()}',
    if (nome.trim().isNotEmpty) 'Nome: ${nome.trim()}',
    '',
    messaggio.trim(),
    '',
    '(Inviato dal modulo Contattaci di PiantalAPP)',
  ];
  return (oggetto: oggetto, testo: righe.join('\n'));
}

/// Link che apre il messaggio già compilato: una mail se c'è l'indirizzo,
/// altrimenti una nuova segnalazione su GitHub.
Uri linkInvio(({String oggetto, String testo}) m, {bool github = false}) {
  if (!github && indirizzoContatti.isNotEmpty) {
    return Uri(
      scheme: 'mailto',
      path: indirizzoContatti,
      query:
          'subject=${Uri.encodeComponent(m.oggetto)}'
          '&body=${Uri.encodeComponent(m.testo)}',
    );
  }
  return Uri.parse('$_repository/issues/new')
      .replace(queryParameters: {'title': m.oggetto, 'body': m.testo});
}

class Contattaci extends StatefulWidget {
  const Contattaci({super.key});

  @override
  State<Contattaci> createState() => _ContattaciState();
}

class _ContattaciState extends State<Contattaci> {
  final _modulo = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _pianta = TextEditingController();
  final _messaggio = TextEditingController();
  Motivo _motivo = Motivo.collaborare;

  @override
  void dispose() {
    _nome.dispose();
    _pianta.dispose();
    _messaggio.dispose();
    super.dispose();
  }

  bool get _chiedePianta =>
      _motivo == Motivo.nuovaPianta || _motivo == Motivo.errore;

  Future<void> _invia({bool github = false}) async {
    if (!_modulo.currentState!.validate()) return;
    final m = componiMessaggio(
      motivo: _motivo,
      messaggio: _messaggio.text,
      nome: _nome.text,
      pianta: _chiedePianta ? _pianta.text : '',
    );
    final aperto = await launchUrl(
      linkInvio(m, github: github),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || aperto) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          github || indirizzoContatti.isEmpty
              ? 'Non riesco ad aprire il browser'
              : 'Non trovo un\'app per la posta: scrivici a $indirizzoContatti',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final conEmail = indirizzoContatti.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Testata(sottotitolo: 'Contattaci')),
      body: Form(
        key: _modulo,
        // Una Column e non una ListView: così tutti i campi esistono sempre e
        // vengono controllati, anche quelli fuori dallo schermo.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scegli di cosa vuoi parlarci e scrivi il tuo messaggio. '
                'Leggiamo tutto e rispondiamo appena possibile.',
              ),
              const SizedBox(height: 16),
              Text('Di cosa si tratta?', style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in Motivo.values)
                    ChoiceChip(
                      avatar: Icon(m.icona, size: 18),
                      showCheckmark: false,
                      label: Text(m.etichetta),
                      selected: _motivo == m,
                      onSelected: (_) => setState(() => _motivo = m),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_chiedePianta) ...[
                TextFormField(
                  controller: _pianta,
                  decoration: InputDecoration(
                    labelText: _motivo == Motivo.nuovaPianta
                        ? 'Quale pianta?'
                        : 'In quale scheda?',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Scrivi il nome della pianta'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(
                  labelText: 'Il tuo nome (facoltativo)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messaggio,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Messaggio',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Scrivi un messaggio' : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _invia,
                icon: Icon(conEmail ? Icons.mail_outline : Icons.send_outlined),
                label: Text(
                  conEmail ? 'Invia con la posta' : 'Invia su GitHub',
                ),
              ),
              if (conEmail) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _invia(github: true),
                  icon: const Icon(Icons.public),
                  label: const Text('Invia su GitHub'),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                conEmail
                    ? 'Con la posta si apre una mail già compilata: controllala '
                          'e premi Invia. Su GitHub il messaggio è pubblico e '
                          'serve un account.'
                    : 'Si apre GitHub con il messaggio già compilato: serve un '
                          'account gratuito e il messaggio sarà pubblico.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
