import 'package:flutter/material.dart';

import '../dati/archivio_piante.dart';
import '../modello/etichette.dart';
import '../modello/filtri.dart';
import '../modello/pianta.dart';
import 'contattaci.dart';
import 'foto.dart';
import 'funghi.dart';
import 'info.dart';
import 'riconosci.dart';
import 'scheda_pianta.dart';
import 'sostieni.dart';
import 'testata.dart';

class ElencoPiante extends StatefulWidget {
  const ElencoPiante({super.key, required this.archivio});

  final ArchivioPiante archivio;

  @override
  State<ElencoPiante> createState() => _ElencoPianteState();
}

class _ElencoPianteState extends State<ElencoPiante> {
  String _testo = '';
  final Set<Filtro> _filtri = {};

  /// Categoria scelta, o null per vederle tutte divise per categoria.
  String? _gruppo;

  /// 0 = piante, 1 = funghi.
  int _sezione = 0;

  Future<void> _aggiorna() async {
    final cambiate = await widget.archivio.aggiorna();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cambiate
              ? 'Schede aggiornate'
              : 'Nessun aggiornamento disponibile o rete assente',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Testata(),
        actions: [
          IconButton(
            tooltip: titoloSostieni,
            icon: const Icon(Icons.favorite_border),
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Sostieni())),
          ),
          PopupMenuButton<Widget Function()>(
            tooltip: 'Menu',
            onSelected: (pagina) =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => pagina())),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: Contattaci.new,
                child: const ListTile(
                  leading: Icon(Icons.mail_outline),
                  title: Text('Contattaci'),
                ),
              ),
              PopupMenuItem(
                value: Info.new,
                child: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Informazioni e contributi'),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sezione,
        onDestinationSelected: (i) => setState(() => _sezione = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Piante',
          ),
          NavigationDestination(
            icon: Icon(Icons.forest_outlined),
            selectedIcon: Icon(Icons.forest),
            label: 'Funghi',
          ),
        ],
      ),
      floatingActionButton: _sezione != 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Riconosci(piante: widget.archivio.piante),
                ),
              ),
              icon: const Icon(Icons.center_focus_weak),
              label: const Text('Riconosci'),
              tooltip: 'Riconosci una pianta da una foto',
            ),
      body: ListenableBuilder(
        listenable: widget.archivio,
        builder: (context, _) {
          if (!widget.archivio.caricato) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_sezione == 1) {
            return RefreshIndicator(
              onRefresh: _aggiorna,
              child: ElencoFunghi(funghi: widget.archivio.funghi),
            );
          }
          final piante = cerca(
            widget.archivio.piante,
            _testo,
            _filtri,
          ).where((p) => _gruppo == null || p.gruppo == _gruppo).toList();
          final voci = _gruppo == null ? perCategoria(piante) : piante;
          return RefreshIndicator(
            onRefresh: _aggiorna,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _barraRicerca()),
                if (piante.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nessuna pianta trovata con questi criteri.',
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: voci.length,
                    itemBuilder: (context, i) => switch (voci[i]) {
                      final Pianta p => _Riga(pianta: p),
                      final String gruppo => _TitoloCategoria(gruppo),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                // Spazio perché il pulsante «Riconosci» non copra l'ultima pianta.
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _barraRicerca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            hintText: 'Cerca una pianta',
            leading: const Icon(Icons.search),
            onChanged: (v) => setState(() => _testo = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Tutte'),
                selected: _gruppo == null,
                onSelected: (_) => setState(() => _gruppo = null),
              ),
              for (final MapEntry(key: gruppo, value: nome)
                  in etichetteGruppo.entries)
                ChoiceChip(
                  label: Text(nome),
                  selected: _gruppo == gruppo,
                  onSelected: (on) =>
                      setState(() => _gruppo = on ? gruppo : null),
                ),
            ],
          ),
          const Divider(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final f in Filtro.values)
                FilterChip(
                  label: Text(f.etichetta),
                  selected: _filtri.contains(f),
                  onSelected: (on) =>
                      setState(() => on ? _filtri.add(f) : _filtri.remove(f)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Le piante divise per categoria: prima del gruppo il suo codice (una
/// stringa, che diventa un titolo), poi le sue piante. I gruppi vuoti
/// non compaiono.
List<Object> perCategoria(List<Pianta> piante) => [
  for (final gruppo in etichetteGruppo.keys)
    if (piante.where((p) => p.gruppo == gruppo).toList() case final g
        when g.isNotEmpty) ...[
      gruppo,
      ...g,
    ],
  // Categorie arrivate con dati più recenti di questa versione dell'app.
  ...piante.where((p) => !etichetteGruppo.containsKey(p.gruppo)),
];

class _TitoloCategoria extends StatelessWidget {
  const _TitoloCategoria(this.gruppo);

  final String gruppo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          etichetta(etichetteGruppo, gruppo),
          style: tema.textTheme.titleSmall?.copyWith(
            color: tema.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga({required this.pianta});

  final Pianta pianta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secondario = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: tema.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SchedaPianta(pianta: pianta)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: FotoPianta(pianta: pianta),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pianta.nome, style: tema.textTheme.titleMedium),
                    Text(
                      pianta.nomeScientifico,
                      style: secondario?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 14,
                          color: secondario?.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            etichetta(etichetteLuce, pianta.luce.ideale),
                            style: secondario,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.speed, size: 14, color: secondario?.color),
                        const SizedBox(width: 4),
                        Text(
                          etichetteDifficolta[pianta.difficolta] ?? '',
                          style: secondario,
                        ),
                      ],
                    ),
                  ],
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
