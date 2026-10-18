import 'package:flutter/material.dart';

import '../modello/etichette.dart';
import '../modello/pianta.dart';
import 'vetrina.dart';

class SchedaPianta extends StatelessWidget {
  const SchedaPianta({super.key, required this.pianta});

  final Pianta pianta;

  @override
  Widget build(BuildContext context) {
    final p = pianta;
    final tema = Theme.of(context);
    final altriNomi = [...?p.nomiComuni['it']?.skip(1), ...p.sinonimi];
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.nomeScientifico,
          style: tema.textTheme.titleLarge?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        if (p.famiglia != null || altriNomi.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              [
                if (p.famiglia != null) 'Famiglia ${p.famiglia}',
                if (altriNomi.isNotEmpty) 'Detta anche ${altriNomi.join(', ')}',
              ].join(' · '),
              style: tema.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
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
            _Pillola(Icons.speed, etichetteDifficolta[p.difficolta] ?? ''),
          ],
        ),
        if (p.descrizione != null) ...[
          const SizedBox(height: 16),
          Text(p.descrizione!, style: tema.textTheme.bodyLarge),
        ],
        if (p.inBozza) ...[
          const SizedBox(height: 16),
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
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(p.nome)),
      body: LayoutBuilder(
        builder: (context, vincoli) {
          final largo = vincoli.maxWidth >= 840;
          // Su schermi grandi il contenuto resta in una colonna leggibile.
          final margine = vincoli.maxWidth > 1132
              ? (vincoli.maxWidth - 1100) / 2
              : 16.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(margine, 8, margine, 32),
            children: [
              if (largo)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 420, child: Vetrina(pianta: p)),
                    const SizedBox(width: 32),
                    Expanded(child: intro),
                  ],
                )
              else ...[
                Vetrina(pianta: p),
                const SizedBox(height: 20),
                intro,
              ],
              const SizedBox(height: 8),
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
          );
        },
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
