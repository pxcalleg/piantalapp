import 'pianta.dart';

/// Filtri rapidi mostrati nell'elenco delle piante.
enum Filtro {
  interno('In casa'),
  esterno('All\'aperto'),
  terrarium('Terrarium'),
  pocaLuce('Poca luce'),
  facile('Facile'),
  sicuraAnimali('Sicura per animali');

  const Filtro(this.etichetta);
  final String etichetta;

  bool accetta(Pianta p) => switch (this) {
    Filtro.interno => p.ambiente.interno,
    Filtro.esterno => p.ambiente.esterno != 'no',
    Filtro.terrarium => p.ambiente.terrarium != 'no',
    Filtro.pocaLuce => p.luce.livelli.contains('bassa'),
    Filtro.facile => p.difficolta <= 2,
    Filtro.sicuraAnimali => p.tossicita.animali == 'non_tossica',
  };
}

/// Piante che contengono [testo] in un nome (comune, scientifico o sinonimo)
/// e rispettano tutti i [filtri], in ordine alfabetico.
List<Pianta> cerca(List<Pianta> piante, String testo, Set<Filtro> filtri) {
  final q = normalizza(testo.trim());
  final risultato = piante.where((p) {
    if (!filtri.every((f) => f.accetta(p))) return false;
    if (q.isEmpty) return true;
    final nomi = [
      p.nomeScientifico,
      ...p.sinonimi,
      for (final nomi in p.nomiComuni.values) ...nomi,
    ];
    return nomi.any((n) => normalizza(n).contains(q));
  }).toList()..sort((a, b) => normalizza(a.nome).compareTo(normalizza(b.nome)));
  return risultato;
}

/// Minuscolo e senza accenti, per una ricerca tollerante.
String normalizza(String s) {
  const accenti = {
    'à': 'a',
    'á': 'a',
    'è': 'e',
    'é': 'e',
    'ì': 'i',
    'í': 'i',
    'ò': 'o',
    'ó': 'o',
    'ù': 'u',
    'ú': 'u',
  };
  final lower = s.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    buf.write(accenti[ch] ?? ch);
  }
  return buf.toString();
}
