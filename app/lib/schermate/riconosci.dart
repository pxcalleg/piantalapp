import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modello/pianta.dart';
import '../modello/riconoscimento.dart';
import 'scheda_pianta.dart';
import 'testata.dart';

Future<Uint8List?> _scegliFoto(ImageSource fonte) async {
  final foto = await ImagePicker().pickImage(
    source: fonte,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 85,
  );
  return foto?.readAsBytes();
}

/// Fotografa una pianta e scopri che specie è, in stile Google Lens.
class Riconosci extends StatefulWidget {
  Riconosci({
    super.key,
    required this.piante,
    RiconoscitorePlantNet? riconoscitore,
    this.sceltaFoto = _scegliFoto,
  }) : riconoscitore = riconoscitore ?? RiconoscitorePlantNet();

  final List<Pianta> piante;
  final RiconoscitorePlantNet riconoscitore;
  final Future<Uint8List?> Function(ImageSource) sceltaFoto;

  @override
  State<Riconosci> createState() => _RiconosciState();
}

class _RiconosciState extends State<Riconosci> {
  Uint8List? _foto;
  bool _inCorso = false;
  String? _errore;
  List<Ipotesi>? _ipotesi;

  Future<void> _usa(ImageSource fonte) async {
    final Uint8List? foto;
    try {
      foto = await widget.sceltaFoto(fonte);
    } catch (_) {
      setState(() => _errore = 'Non riesco ad aprire la fotocamera o le foto.');
      return;
    }
    if (foto == null || !mounted) return;
    setState(() {
      _foto = foto;
      _inCorso = true;
      _errore = null;
      _ipotesi = null;
    });
    try {
      final ipotesi = await widget.riconoscitore.riconosci(foto);
      if (mounted) setState(() => _ipotesi = ipotesi);
    } on ErroreRiconoscimento catch (e) {
      if (mounted) setState(() => _errore = e.messaggio);
    } finally {
      if (mounted) setState(() => _inCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final attivo = widget.riconoscitore.attivo;
    return Scaffold(
      appBar: AppBar(title: const Testata(sottotitolo: 'Riconosci una pianta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!attivo)
            Card(
              elevation: 0,
              color: tema.colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Il riconoscimento delle piante non è ancora attivo in '
                  'questa versione dell\'app. Arriverà con il prossimo '
                  'aggiornamento.',
                ),
              ),
            )
          else ...[
            const Text(
              'Fotografa una foglia o un fiore da vicino, ben a fuoco e con '
              'una sola pianta nell\'inquadratura.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _inCorso ? null : () => _usa(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Scatta una foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _inCorso
                        ? null
                        : () => _usa(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Dalla galleria'),
                  ),
                ),
              ],
            ),
          ],
          if (_foto != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                _foto!,
                height: 240,
                fit: BoxFit.cover,
                semanticLabel: 'La tua foto',
              ),
            ),
          ],
          if (_inCorso) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Sto riconoscendo la pianta…'),
          ],
          if (_errore != null) ...[
            const SizedBox(height: 16),
            Text(_errore!, style: TextStyle(color: tema.colorScheme.error)),
          ],
          if (_ipotesi != null) ...[
            const SizedBox(height: 20),
            if (_ipotesi!.isEmpty)
              const Text(
                'Non sono riuscito a riconoscere la pianta. Prova con una foto '
                'più vicina a una foglia o a un fiore.',
              )
            else ...[
              Text('Potrebbe essere', style: tema.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final i in _ipotesi!)
                _RigaIpotesi(ipotesi: i, piante: widget.piante),
            ],
          ],
          if (attivo) ...[
            const SizedBox(height: 24),
            Text(
              'Il riconoscimento è offerto da Pl@ntNet. La foto viene inviata '
              'al servizio solo per l\'analisi e non viene conservata.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://plantnet.org'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Powered by Pl@ntNet'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RigaIpotesi extends StatelessWidget {
  const _RigaIpotesi({required this.ipotesi, required this.piante});

  final Ipotesi ipotesi;
  final List<Pianta> piante;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final collegate = schedeCollegate(piante, ipotesi);
    final secondario = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: tema.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ipotesi.nomiComuni.firstOrNull ?? ipotesi.nomeScientifico,
                    style: tema.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${ipotesi.percentuale}%',
                  style: tema.textTheme.labelLarge?.copyWith(
                    color: tema.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              ipotesi.nomeScientifico,
              style: secondario?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 6),
            if (collegate.stessaSpecie.isNotEmpty)
              _Collegamenti(piante: collegate.stessaSpecie)
            else if (collegate.stessoGenere.isNotEmpty) ...[
              Text('Simili in archivio:', style: secondario),
              _Collegamenti(piante: collegate.stessoGenere),
            ] else
              Text(
                'Non ancora presente nelle nostre schede',
                style: secondario,
              ),
          ],
        ),
      ),
    );
  }
}

class _Collegamenti extends StatelessWidget {
  const _Collegamenti({required this.piante});

  final List<Pianta> piante;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final p in piante)
          ActionChip(
            avatar: const Icon(Icons.eco_outlined, size: 18),
            label: Text('Apri la scheda: ${p.nome}'),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => SchedaPianta(pianta: p))),
          ),
      ],
    );
  }
}
