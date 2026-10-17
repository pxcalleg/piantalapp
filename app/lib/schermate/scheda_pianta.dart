import 'package:flutter/material.dart';

import '../modello/etichette.dart';
import '../modello/pianta.dart';
import '../visuale/modelli.dart';
import '../visuale/stato_pianta.dart';
import 'foto.dart';
import 'simulatore.dart';

class SchedaPianta extends StatelessWidget {
  const SchedaPianta({super.key, required this.pianta});

  final Pianta pianta;

  @override
  Widget build(BuildContext context) {
    final p = pianta;
    final tema = Theme.of(context);
    final altriNomi = [...?p.nomiComuni['it']?.skip(1), ...p.sinonimi];
    final foto = p.immagini.firstOrNull;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: foto == null ? null : 340,
            foregroundColor: foto == null ? null : Colors.white,
            title: foto == null ? Text(p.nome) : null,
            flexibleSpace: foto == null
                ? null
                : FlexibleSpaceBar(
                    title: Text(
                      p.nome,
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        FotoPianta(pianta: p),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Color(0x00000000),
                                Color(0x99000000),
                              ],
                              stops: [0, 0.4, 1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList.list(
              children: [
                if (foto != null) CreditoFoto(immagine: foto),
                const SizedBox(height: 8),
                Text(
                  p.nomeScientifico,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (p.famiglia != null || altriNomi.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if (p.famiglia != null) 'Famiglia ${p.famiglia}',
                        if (altriNomi.isNotEmpty)
                          'Detta anche ${altriNomi.join(', ')}',
                      ].join(' · '),
                      style: tema.textTheme.bodySmall,
                    ),
                  ),
                if (p.inBozza) ...[
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tema.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 20,
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Scheda in bozza, non ancora controllata da un esperto.',
                              style: tema.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (p.descrizione != null) ...[
                  const SizedBox(height: 12),
                  Text(p.descrizione!, style: tema.textTheme.bodyLarge),
                ],
                if (modelliVisuali.containsKey(p.id)) ...[
                  const SizedBox(height: 20),
                  _Anteprima(pianta: p),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pillola(
                      Icons.wb_sunny_outlined,
                      etichetta(etichetteLuce, p.luce.ideale),
                    ),
                    _Pillola(
                      Icons.water_drop_outlined,
                      'Estate ${p.annaffiatura.primaveraEstate}',
                    ),
                    _Pillola(Icons.thermostat, 'Min ${p.temperatura.minC} °C'),
                    _Pillola(
                      Icons.speed,
                      etichetteDifficolta[p.difficolta] ?? '',
                    ),
                  ],
                ),
                _Sezione(
                  icona: Icons.home_outlined,
                  titolo: 'Dove tenerla',
                  voci: [
                    ('In casa', p.ambiente.interno ? 'Sì' : 'No'),
                    (
                      'All\'aperto',
                      etichetta(etichetteEsterno, p.ambiente.esterno),
                    ),
                    (
                      'Terrarium',
                      etichetta(etichetteTerrarium, p.ambiente.terrarium),
                    ),
                    if (p.ambiente.note != null) ('', p.ambiente.note!),
                  ],
                ),
                _Sezione(
                  icona: Icons.wb_sunny_outlined,
                  titolo: 'Luce ed esposizione',
                  voci: [
                    ('Ideale', etichetta(etichetteLuce, p.luce.ideale)),
                    if (p.luce.tollera.isNotEmpty)
                      (
                        'Tollera',
                        p.luce.tollera
                            .map((l) => etichetta(etichetteLuce, l))
                            .join(', '),
                      ),
                    if (p.luce.soleDiretto != null)
                      (
                        'Sole diretto',
                        etichetta(etichetteSoleDiretto, p.luce.soleDiretto),
                      ),
                    if (p.luce.esposizione.isNotEmpty)
                      (
                        'Finestre',
                        p.luce.esposizione
                            .map((e) => etichetta(etichetteEsposizione, e))
                            .join(', '),
                      ),
                    if (p.luce.note != null) ('', p.luce.note!),
                  ],
                ),
                _Sezione(
                  icona: Icons.water_drop_outlined,
                  titolo: 'Annaffiatura',
                  voci: [
                    ('Quando', p.annaffiatura.quando),
                    (
                      'Primavera ed estate',
                      'Indicativamente ${p.annaffiatura.primaveraEstate}',
                    ),
                    (
                      'Autunno e inverno',
                      'Indicativamente ${p.annaffiatura.autunnoInverno}',
                    ),
                    if (p.annaffiatura.metodo != null)
                      ('Come', p.annaffiatura.metodo!),
                    if (p.annaffiatura.acqua != null)
                      ('Acqua', p.annaffiatura.acqua!),
                    if (p.annaffiatura.segnaliTroppa != null)
                      ('Troppa acqua', p.annaffiatura.segnaliTroppa!),
                    if (p.annaffiatura.segnaliPoca != null)
                      ('Poca acqua', p.annaffiatura.segnaliPoca!),
                    if (p.umidita != null)
                      (
                        'Umidità dell\'aria',
                        etichetta(etichetteUmidita, p.umidita),
                      ),
                  ],
                ),
                _Sezione(
                  icona: Icons.science_outlined,
                  titolo: 'Concimazione',
                  voci: [
                    ('Periodo', descriviMesi(p.concimazione.mesi)),
                    ('Frequenza', p.concimazione.frequenza.toString()),
                    ('Tipo', p.concimazione.tipo),
                    if (p.concimazione.note != null) ('', p.concimazione.note!),
                  ],
                ),
                _Sezione(
                  icona: Icons.thermostat,
                  titolo: 'Temperatura',
                  voci: [
                    (
                      'Ideale',
                      '${p.temperatura.idealeMinC}-${p.temperatura.idealeMaxC} °C',
                    ),
                    ('Minima', '${p.temperatura.minC} °C'),
                    if (p.temperatura.note != null) ('', p.temperatura.note!),
                  ],
                ),
                _Sezione(
                  icona: Icons.grass,
                  titolo: 'Terreno, rinvaso e propagazione',
                  voci: [
                    if (p.terreno != null) ('Terreno', p.terreno!),
                    if (p.rinvaso != null) ('Rinvaso', p.rinvaso!),
                    if (p.propagazione.isNotEmpty)
                      (
                        'Si moltiplica per',
                        p.propagazione
                            .map((m) => etichetta(etichettePropagazione, m))
                            .join(', '),
                      ),
                  ],
                ),
                _Sezione(
                  icona: Icons.pets,
                  titolo: 'Tossicità',
                  voci: [
                    (
                      'Animali',
                      etichetta(etichetteTossicita, p.tossicita.animali),
                    ),
                    (
                      'Persone',
                      etichetta(etichetteTossicita, p.tossicita.persone),
                    ),
                    if (p.tossicita.note != null) ('', p.tossicita.note!),
                  ],
                ),
                if (p.problemiComuni.isNotEmpty)
                  _Sezione(
                    icona: Icons.healing_outlined,
                    titolo: 'Problemi comuni',
                    voci: [
                      for (final pr in p.problemiComuni)
                        (pr.sintomo, '${pr.causa}. ${pr.rimedio}'),
                    ],
                  ),
                _Sezione(
                  icona: Icons.menu_book_outlined,
                  titolo: 'Fonti e autori',
                  voci: [
                    for (final f in p.fonti) ('', f),
                    ('Autori', p.autori.join(', ')),
                    ('Aggiornata', p.aggiornato),
                    ('Licenza', 'CC BY-SA 4.0'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pillola extends StatelessWidget {
  const _Pillola(this.icona, this.testo);

  final IconData icona;
  final String testo;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icona, size: 18), label: Text(testo));
}

class _Sezione extends StatelessWidget {
  const _Sezione({
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

/// Illustrazione in testa alla scheda; se esiste un modello interattivo,
/// un tocco apre il simulatore.
class _Anteprima extends StatelessWidget {
  const _Anteprima({required this.pianta});

  final Pianta pianta;

  void _apri(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Simulatore(pianta: pianta)));

  @override
  Widget build(BuildContext context) {
    final pittore = modelliVisuali[pianta.id];
    if (pittore == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _apri(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: pittore(const StatoPianta(), 0.5, 0.6)),
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.tonalIcon(
                  onPressed: () => _apri(context),
                  icon: const Icon(Icons.threesixty),
                  label: const Text('Ruota e simula'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
