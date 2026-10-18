/// Testi in italiano per i valori codificati delle schede.
const etichetteLuce = {
  'bassa': 'Poca luce',
  'media_indiretta': 'Luce indiretta',
  'intensa_indiretta': 'Molta luce indiretta',
  'sole_diretto': 'Sole diretto',
};

const etichetteSoleDiretto = {
  'no': 'No, brucia le foglie',
  'solo_mattino': 'Solo il sole del mattino',
  'si': 'Sì',
};

const etichetteEsterno = {
  'no': 'No',
  'estate': 'Solo nella bella stagione',
  'tutto_anno': 'Tutto l\'anno',
};

const etichetteTerrarium = {
  'no': 'No',
  'aperto': 'Terrarium aperto',
  'chiuso': 'Terrarium chiuso',
  'entrambi': 'Terrarium aperto o chiuso',
};

const etichetteUmidita = {'bassa': 'Bassa', 'media': 'Media', 'alta': 'Alta'};

const etichetteTossicita = {
  'non_tossica': 'Non tossica',
  'lieve': 'Lievemente tossica',
  'tossica': 'Tossica',
  'sconosciuta': 'Non nota',
};

const etichettePropagazione = {
  'talea_fusto': 'talea di fusto',
  'talea_foglia': 'talea di foglia',
  'talea_in_acqua': 'talea in acqua',
  'divisione': 'divisione del cespo',
  'seme': 'seme',
  'margotta': 'margotta',
  'propaggine': 'propaggine',
  'polloni': 'polloni (piantine figlie)',
  'innesto': 'innesto',
};

const etichetteEsposizione = {
  'nord': 'nord',
  'est': 'est',
  'sud': 'sud',
  'ovest': 'ovest',
};

const etichetteDifficolta = {
  1: 'Facilissima',
  2: 'Facile',
  3: 'Media',
  4: 'Impegnativa',
  5: 'Per esperti',
};

const nomiMesi = [
  'gen',
  'feb',
  'mar',
  'apr',
  'mag',
  'giu',
  'lug',
  'ago',
  'set',
  'ott',
  'nov',
  'dic',
];

String etichetta(Map<String, String> mappa, String? valore) =>
    valore == null ? '' : (mappa[valore] ?? valore);

/// "mar-set" se i mesi sono consecutivi, altrimenti l'elenco.
String descriviMesi(List<int> mesi) {
  if (mesi.isEmpty) return 'mai';
  final ordinati = [...mesi]..sort();
  final consecutivi = ordinati.last - ordinati.first == ordinati.length - 1;
  if (consecutivi && ordinati.length > 2) {
    return '${nomiMesi[ordinati.first - 1]}-${nomiMesi[ordinati.last - 1]}';
  }
  return ordinati.map((m) => nomiMesi[m - 1]).join(', ');
}
