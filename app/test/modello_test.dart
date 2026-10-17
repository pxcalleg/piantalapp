import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:piantalapp/dati/archivio_piante.dart';
import 'package:piantalapp/modello/etichette.dart';
import 'package:piantalapp/modello/filtri.dart';

void main() {
  final piante = leggiPacchetto(File('assets/piante.json').readAsStringSync())!;
  final perId = {for (final p in piante) p.id: p};

  test('legge tutte le schede incluse nell\'app', () {
    expect(piante, hasLength(greaterThanOrEqualTo(5)));
    expect(perId['pothos']!.nomeScientifico, 'Epipremnum aureum');
    expect(perId['pothos']!.nome, 'Pothos');
    expect(perId['sansevieria']!.annaffiatura.autunnoInverno.max, 45);
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
    expect(sicure.map((p) => p.id), ['fittonia']);
  });

  test('descrive i mesi di concimazione', () {
    expect(descriviMesi([3, 4, 5, 6, 7, 8, 9]), 'mar-set');
    expect(descriviMesi([4, 9]), 'apr, set');
    expect(descriviMesi([]), 'mai');
  });
}
