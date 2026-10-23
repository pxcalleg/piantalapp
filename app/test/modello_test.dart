import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/modello/etichette.dart';
import 'package:piantalapp/modello/filtri.dart';
import 'package:piantalapp/modello/pianta.dart';

void main() {
  final piante = leggiPacchetto(File('assets/piante.json').readAsStringSync())!;
  final perId = {for (final p in piante) p.id: p};

  test('legge tutte le schede incluse nell\'app', () {
    expect(piante, hasLength(greaterThanOrEqualTo(5)));
    expect(perId['pothos']!.nomeScientifico, 'Epipremnum aureum');
    expect(perId['pothos']!.nome, 'Pothos');
    expect(perId['sansevieria']!.annaffiatura.autunnoInverno.max, 45);
  });

  test('ogni pianta spiega come si propaga, metodo per metodo', () {
    for (final p in piante) {
      expect(p.comeSiPropaga, isNotEmpty, reason: p.id);
      expect(
        p.comeSiPropaga.map((g) => g.metodo).toSet(),
        p.propagazione.toSet(),
        reason: p.id,
      );
      for (final g in p.comeSiPropaga) {
        expect(etichettePropagazione, contains(g.metodo));
        expect(g.passi.length, greaterThanOrEqualTo(2));
      }
    }
    final pothos = perId['pothos']!.comeSiPropaga;
    expect(pothos.first.metodo, 'talea_in_acqua');
    expect(pothos.first.difficolta, 'facile');
  });

  test('ignora un pacchetto con schema più recente', () {
    expect(leggiPacchetto('{"schema_version": 99, "piante": []}'), isNull);
  });

  test('la ricerca trova per nome comune, scientifico e sinonimo', () {
    List<String> ids(String q) =>
        cerca(piante, q, {}).map((p) => p.id).toList();
    expect(ids('lingua di suocera'), ['sansevieria']);
    expect(ids('epipremnum'), ['pothos']);
    expect(ids('scindapsus'), ['pothos']);
    expect(ids('PIANGENTE'), ['ficus-benjamina']);
  });

  test('i filtri si combinano', () {
    final terrarium = cerca(piante, '', {Filtro.terrarium}).map((p) => p.id);
    expect(terrarium, containsAll(['fittonia', 'pothos']));
    expect(terrarium, isNot(contains('sansevieria')));

    final sicure = cerca(piante, '', {Filtro.terrarium, Filtro.sicuraAnimali});
    expect(sicure.map((p) => p.id), contains('fittonia'));
    expect(sicure.map((p) => p.id), isNot(contains('pothos')));
  });

  test('descrive i mesi di concimazione', () {
    expect(descriviMesi([3, 4, 5, 6, 7, 8, 9]), 'mar-set');
    expect(descriviMesi([4, 9]), 'apr, set');
    expect(descriviMesi([12, 1, 2, 3]), 'dic-mar');
    expect(descriviMesi([9, 10, 11, 12]), 'set-dic');
    expect(descriviMesi([]), 'mai');
  });

  test('ogni foto ha la sua copia nell\'app e i dati per citare l\'autore', () {
    for (final p in piante) {
      for (final i in p.immagini) {
        expect(File(i.asset).existsSync(), isTrue, reason: i.asset);
        expect(i.autore, isNotEmpty);
        expect(i.licenza, matches(RegExp(r'^(CC|Public)')));
      }
    }
  });

  test('un aggiornamento non sostituisce schede più recenti', () {
    final incluse = [perId['pothos']!, perId['fittonia']!];
    final vecchio = Pianta.fromJson({
      ..._json('pothos'),
      'aggiornato': '2000-01-01',
      'immagini': <Object>[],
    });
    final nuova = Pianta.fromJson({
      ..._json('fittonia'),
      'aggiornato': '2999-01-01',
    });
    final unite = {
      for (final p in unisci(incluse, [vecchio, nuova])) p.id: p,
    };
    expect(unite['pothos'], same(perId['pothos']));
    expect(unite['fittonia'], same(nuova));
  });
}

Map<String, dynamic> _json(String id) {
  final dati = jsonDecode(
    File('assets/piante.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return (dati['piante'] as List).cast<Map<String, dynamic>>().firstWhere(
    (p) => p['id'] == id,
  );
}
