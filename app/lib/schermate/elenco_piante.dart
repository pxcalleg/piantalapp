import 'package:flutter/material.dart';

import '../dati/archivio_piante.dart';
import '../modello/etichette.dart';
import '../modello/filtri.dart';
import '../modello/pianta.dart';
import 'contattaci.dart';
import 'foto.dart';
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
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', width: 32, height: 32),
            ),
            const SizedBox(width: 10),
            const Text('PiantalAPP'),
          ],
        ),
        actions: [
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
