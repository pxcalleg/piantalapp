import 'package:flutter/material.dart';

import '../dati/archivio_piante.dart';
import '../modello/etichette.dart';
import '../modello/filtri.dart';
import '../modello/pianta.dart';
import 'info.dart';
import 'scheda_pianta.dart';

class ElencoPiante extends StatefulWidget {
  const ElencoPiante({super.key, required this.archivio});

  final ArchivioPiante archivio;

  @override
  State<ElencoPiante> createState() => _ElencoPianteState();
}

class _ElencoPianteState extends State<ElencoPiante> {
  String _testo = '';
  final Set<Filtro> _filtri = {};

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
        title: const Text('PiantalAPP'),
        actions: [
          IconButton(
            tooltip: 'Informazioni e contributi',
            icon: const Icon(Icons.info_outline),
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const Info())),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.archivio,
        builder: (context, _) {
          if (!widget.archivio.caricato) {
            return const Center(child: CircularProgressIndicator());
          }
          final piante = cerca(widget.archivio.piante, _testo, _filtri);
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
                    itemCount: piante.length,
                    itemBuilder: (context, i) => _Riga(pianta: piante[i]),
                  ),
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

class _Riga extends StatelessWidget {
  const _Riga({required this.pianta});

  final Pianta pianta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tema.colorScheme.primaryContainer,
        child: Icon(
          Icons.local_florist,
          color: tema.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(pianta.nome),
      subtitle: Text(
        '${pianta.nomeScientifico} · ${etichetteDifficolta[pianta.difficolta]}',
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SchedaPianta(pianta: pianta))),
    );
  }
}
