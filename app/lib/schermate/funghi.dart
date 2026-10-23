import 'package:flutter/material.dart';

import '../modello/etichette.dart';
import '../modello/filtri.dart';
import '../modello/fungo.dart';
import 'foto.dart';
import 'sezione.dart';
import 'testata.dart';

const testoAvvisoFunghi =
    'Queste schede servono solo a conoscere i funghi, non a riconoscerli. '
    'Non usarle per decidere se un fungo raccolto si può mangiare: molti '
    'funghi mortali somigliano a quelli buoni. Prima di consumarli falli '
    'controllare, gratis, dall\'Ispettorato micologico della tua ASL.';

/// Funghi che contengono [testo] in un nome comune o scientifico, in ordine
/// alfabetico.
List<Fungo> cercaFunghi(List<Fungo> funghi, String testo) {
  final q = normalizza(testo.trim());
  return funghi.where((f) {
    if (q.isEmpty) return true;
    final nomi = [
      f.nomeScientifico,
      ...f.sinonimi,
      for (final nomi in f.nomiComuni.values) ...nomi,
    ];
    return nomi.any((n) => normalizza(n).contains(q));
  }).toList()..sort((a, b) => normalizza(a.nome).compareTo(normalizza(b.nome)));
}

/// Riquadro rosso, sempre visibile in cima all'elenco e a ogni scheda.
class AvvisoFunghi extends StatelessWidget {
  const AvvisoFunghi({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colore = tema.colorScheme.onErrorContainer;
    return Semantics(
      container: true,
      label: 'Attenzione. $testoAvvisoFunghi',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tema.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: colore),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attenzione: rischio di avvelenamento',
                      style: tema.textTheme.titleSmall?.copyWith(color: colore),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      testoAvvisoFunghi,
                      style: tema.textTheme.bodySmall?.copyWith(color: colore),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nome comune seguito dal nome latino tra parentesi, in corsivo.
class NomeFungo extends StatelessWidget {
  const NomeFungo({
    super.key,
    required this.nome,
    required this.nomeScientifico,
    this.stile,
  });

  final String nome;
  final String nomeScientifico;
  final TextStyle? stile;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: '$nome ('),
        TextSpan(
          text: nomeScientifico,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const TextSpan(text: ')'),
      ],
    ),
    style: stile,
  );
}

/// Commestibilità, in rosso per i funghi tossici e mortali.
class EtichettaCommestibilita extends StatelessWidget {
  const EtichettaCommestibilita(this.valore, {super.key});

  final String valore;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final pericoloso = valore == 'tossico' || valore == 'mortale';
    final (sfondo, testo) = switch (valore) {
      'tossico' ||
      'mortale' => (schema.errorContainer, schema.onErrorContainer),
      'non_commestibile' => (
        schema.surfaceContainerHighest,
        schema.onSurfaceVariant,
      ),
      _ => (schema.secondaryContainer, schema.onSecondaryContainer),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: sfondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pericoloso) ...[
              Icon(Icons.dangerous_outlined, size: 14, color: testo),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                etichetta(etichetteCommestibilita, valore),
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: testo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenuto della sezione Funghi: avviso, ricerca ed elenco.
class ElencoFunghi extends StatefulWidget {
  const ElencoFunghi({super.key, required this.funghi});

  final List<Fungo> funghi;

  @override
  State<ElencoFunghi> createState() => _ElencoFunghiState();
}

class _ElencoFunghiState extends State<ElencoFunghi> {
  String _testo = '';

  @override
  Widget build(BuildContext context) {
    final funghi = cercaFunghi(widget.funghi, _testo);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                SearchBar(
                  hintText: 'Cerca un fungo',
                  leading: const Icon(Icons.search),
                  onChanged: (v) => setState(() => _testo = v),
                ),
                const SizedBox(height: 12),
                const AvvisoFunghi(),
              ],
            ),
          ),
        ),
        if (funghi.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nessun fungo trovato.'),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: funghi.length,
            itemBuilder: (context, i) => _RigaFungo(fungo: funghi[i]),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _RigaFungo extends StatelessWidget {
  const _RigaFungo({required this.fungo});

  final Fungo fungo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: tema.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => SchedaFungo(fungo: fungo))),
          child: Row(
            children: [
              SizedBox(width: 96, height: 96, child: FotoFungo(fungo: fungo)),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NomeFungo(
                        nome: fungo.nome,
                        nomeScientifico: fungo.nomeScientifico,
                        stile: tema.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          EtichettaCommestibilita(fungo.commestibilita),
                          Text(
                            descriviMesi(fungo.stagione),
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: tema.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SchedaFungo extends StatelessWidget {
  const SchedaFungo({super.key, required this.fungo});

  final Fungo fungo;

  @override
  Widget build(BuildContext context) {
    final f = fungo;
    final tema = Theme.of(context);
    final altriNomi = [...?f.nomiComuni['it']?.skip(1), ...f.sinonimi];
    final c = f.caratteristiche;
    return Scaffold(
      appBar: AppBar(title: Testata(sottotitolo: f.nome)),
      body: LayoutBuilder(
        builder: (context, vincoli) {
          final margine = vincoli.maxWidth > 832
              ? (vincoli.maxWidth - 800) / 2
              : 16.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(margine, 8, margine, 32),
            children: [
              if (f.immagini.firstOrNull case final foto?) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: FotoFungo(fungo: f),
                  ),
                ),
                CreditoFoto(immagine: foto),
                const SizedBox(height: 12),
              ],
              NomeFungo(
                nome: f.nome,
                nomeScientifico: f.nomeScientifico,
                stile: tema.textTheme.headlineSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  [
                    'Famiglia ${f.famiglia}',
                    if (altriNomi.isNotEmpty)
                      'Detto anche ${altriNomi.join(', ')}',
                  ].join(' · '),
                  style: tema.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: EtichettaCommestibilita(f.commestibilita),
              ),
              const SizedBox(height: 16),
              const AvvisoFunghi(),
              const SizedBox(height: 16),
              Text(f.descrizione, style: tema.textTheme.bodyLarge),
              if (f.inBozza)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Scheda in bozza, non ancora controllata da un micologo.',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              SezioneScheda(
                icona: Icons.restaurant_outlined,
                titolo: 'Commestibilità',
                voci: [
                  ('', etichetta(etichetteCommestibilita, f.commestibilita)),
                  if (f.noteCommestibilita != null) ('', f.noteCommestibilita!),
                ],
              ),
              SezioneScheda(
                icona: Icons.forest_outlined,
                titolo: 'Dove e quando',
                voci: [
                  ('Habitat', f.habitat),
                  ('Stagione', descriviMesi(f.stagione)),
                ],
              ),
              SezioneScheda(
                icona: Icons.search,
                titolo: 'Come è fatto',
                voci: [
                  ('Cappello', c.cappello),
                  ('Sotto il cappello', c.sottoIlCappello),
                  ('Gambo', c.gambo),
                  ('Carne', c.carne),
                  if (c.sporata != null) ('Sporata', c.sporata!),
                ],
              ),
              if (f.sosia.isNotEmpty) _Sosia(f.sosia),
              if (f.curiosita != null)
                SezioneScheda(
                  icona: Icons.lightbulb_outline,
                  titolo: 'Curiosità',
                  voci: [('', f.curiosita!)],
                ),
              SezioneScheda(
                icona: Icons.menu_book_outlined,
                titolo: 'Fonti e autori',
                voci: [
                  for (final fonte in f.fonti) ('', fonte),
                  ('Autori', f.autori.join(', ')),
                  ('Aggiornata', f.aggiornato),
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

class _Sosia extends StatelessWidget {
  const _Sosia(this.sosia);

  final List<Sosia> sosia;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: tema.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Con cosa si può confondere',
                  style: tema.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          for (final s in sosia)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tema.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NomeFungo(
                    nome: s.nome,
                    nomeScientifico: s.nomeScientifico,
                    stile: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  EtichettaCommestibilita(s.commestibilita),
                  const SizedBox(height: 6),
                  Text(s.differenze),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
