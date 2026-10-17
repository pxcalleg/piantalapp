/// Scheda di una pianta, come definita in schema/pianta.schema.json.
class Pianta {
  const Pianta({
    required this.id,
    required this.stato,
    required this.nomeScientifico,
    required this.nomiComuni,
    required this.categorie,
    required this.ambiente,
    required this.difficolta,
    required this.luce,
    required this.annaffiatura,
    required this.concimazione,
    required this.temperatura,
    required this.tossicita,
    required this.fonti,
    required this.autori,
    required this.aggiornato,
    this.sinonimi = const [],
    this.famiglia,
    this.descrizione,
    this.umidita,
    this.terreno,
    this.rinvaso,
    this.propagazione = const [],
    this.problemiComuni = const [],
  });

  final String id;
  final String stato;
  final String nomeScientifico;
  final List<String> sinonimi;
  final String? famiglia;
  final Map<String, List<String>> nomiComuni;
  final String? descrizione;
  final List<String> categorie;
  final Ambiente ambiente;
  final int difficolta;
  final Luce luce;
  final Annaffiatura annaffiatura;
  final String? umidita;
  final Concimazione concimazione;
  final Temperatura temperatura;
  final String? terreno;
  final String? rinvaso;
  final List<String> propagazione;
  final Tossicita tossicita;
  final List<ProblemaComune> problemiComuni;
  final List<String> fonti;
  final List<String> autori;
  final String aggiornato;

  /// Nome principale in italiano, o il nome scientifico se manca.
  String get nome => nomiComuni['it']?.first ?? nomeScientifico;

  bool get inBozza => stato != 'revisionata';

  factory Pianta.fromJson(Map<String, dynamic> j) => Pianta(
    id: j['id'] as String,
    stato: j['stato'] as String,
    nomeScientifico: j['nome_scientifico'] as String,
    sinonimi: _stringhe(j['sinonimi']),
    famiglia: j['famiglia'] as String?,
    nomiComuni: (j['nomi_comuni'] as Map<String, dynamic>).map(
      (lingua, nomi) => MapEntry(lingua, _stringhe(nomi)),
    ),
    descrizione: j['descrizione'] as String?,
    categorie: _stringhe(j['categorie']),
    ambiente: Ambiente.fromJson(j['ambiente'] as Map<String, dynamic>),
    difficolta: j['difficolta'] as int,
    luce: Luce.fromJson(j['luce'] as Map<String, dynamic>),
    annaffiatura: Annaffiatura.fromJson(
      j['annaffiatura'] as Map<String, dynamic>,
    ),
    umidita: j['umidita'] as String?,
    concimazione: Concimazione.fromJson(
      j['concimazione'] as Map<String, dynamic>,
    ),
    temperatura: Temperatura.fromJson(j['temperatura'] as Map<String, dynamic>),
    terreno: j['terreno'] as String?,
    rinvaso: j['rinvaso'] as String?,
    propagazione: _stringhe(j['propagazione']),
    tossicita: Tossicita.fromJson(j['tossicita'] as Map<String, dynamic>),
    problemiComuni: ((j['problemi_comuni'] as List?) ?? const [])
        .map((p) => ProblemaComune.fromJson(p as Map<String, dynamic>))
        .toList(),
    fonti: _stringhe(j['fonti']),
    autori: _stringhe(j['autori']),
    aggiornato: j['aggiornato'] as String,
  );
}

class Ambiente {
  const Ambiente({
    required this.interno,
    required this.esterno,
    this.terrarium = 'no',
    this.note,
  });

  final bool interno;

  /// 'no', 'estate' o 'tutto_anno'.
  final String esterno;

  /// 'no', 'aperto', 'chiuso' o 'entrambi'.
  final String terrarium;
  final String? note;

  factory Ambiente.fromJson(Map<String, dynamic> j) => Ambiente(
    interno: j['interno'] as bool,
    esterno: j['esterno'] as String,
    terrarium: (j['terrarium'] as String?) ?? 'no',
    note: j['note'] as String?,
  );
}

class Luce {
  const Luce({
    required this.ideale,
    required this.tollera,
    this.soleDiretto,
    this.esposizione = const [],
    this.note,
  });

  final String ideale;
  final List<String> tollera;
  final String? soleDiretto;
  final List<String> esposizione;
  final String? note;

  /// Tutti i livelli di luce in cui la pianta può vivere.
  Set<String> get livelli => {ideale, ...tollera};

  factory Luce.fromJson(Map<String, dynamic> j) => Luce(
    ideale: j['ideale'] as String,
    tollera: _stringhe(j['tollera']),
    soleDiretto: j['sole_diretto'] as String?,
    esposizione: _stringhe(j['esposizione']),
    note: j['note'] as String?,
  );
}

class IntervalloGiorni {
  const IntervalloGiorni(this.min, this.max);
  final int min;
  final int max;

  factory IntervalloGiorni.fromJson(Map<String, dynamic> j) =>
      IntervalloGiorni(j['min'] as int, j['max'] as int);

  @override
  String toString() =>
      min == max ? 'ogni $min giorni' : 'ogni $min-$max giorni';
}

class Annaffiatura {
  const Annaffiatura({
    required this.quando,
    required this.primaveraEstate,
    required this.autunnoInverno,
    this.metodo,
    this.acqua,
    this.segnaliTroppa,
    this.segnaliPoca,
  });

  final String quando;
  final IntervalloGiorni primaveraEstate;
  final IntervalloGiorni autunnoInverno;
  final String? metodo;
  final String? acqua;
  final String? segnaliTroppa;
  final String? segnaliPoca;

  factory Annaffiatura.fromJson(Map<String, dynamic> j) => Annaffiatura(
    quando: j['quando'] as String,
    primaveraEstate: IntervalloGiorni.fromJson(
      j['primavera_estate'] as Map<String, dynamic>,
    ),
    autunnoInverno: IntervalloGiorni.fromJson(
      j['autunno_inverno'] as Map<String, dynamic>,
    ),
    metodo: j['metodo'] as String?,
    acqua: j['acqua'] as String?,
    segnaliTroppa: j['segnali_troppa'] as String?,
    segnaliPoca: j['segnali_poca'] as String?,
  );
}

class Concimazione {
  const Concimazione({
    required this.mesi,
    required this.frequenza,
    required this.tipo,
    this.note,
  });

  final List<int> mesi;
  final IntervalloGiorni frequenza;
  final String tipo;
  final String? note;

  factory Concimazione.fromJson(Map<String, dynamic> j) => Concimazione(
    mesi: ((j['mesi'] as List?) ?? const []).cast<int>(),
    frequenza: IntervalloGiorni.fromJson(
      j['frequenza_giorni'] as Map<String, dynamic>,
    ),
    tipo: j['tipo'] as String,
    note: j['note'] as String?,
  );
}

class Temperatura {
  const Temperatura({
    required this.minC,
    required this.idealeMinC,
    required this.idealeMaxC,
    this.note,
  });

  final num minC;
  final num idealeMinC;
  final num idealeMaxC;
  final String? note;

  factory Temperatura.fromJson(Map<String, dynamic> j) => Temperatura(
    minC: j['min_c'] as num,
    idealeMinC: j['ideale_min_c'] as num,
    idealeMaxC: j['ideale_max_c'] as num,
    note: j['note'] as String?,
  );
}

class Tossicita {
  const Tossicita({required this.animali, required this.persone, this.note});

  final String animali;
  final String persone;
  final String? note;

  factory Tossicita.fromJson(Map<String, dynamic> j) => Tossicita(
    animali: j['animali'] as String,
    persone: j['persone'] as String,
    note: j['note'] as String?,
  );
}

class ProblemaComune {
  const ProblemaComune({
    required this.sintomo,
    required this.causa,
    required this.rimedio,
  });

  final String sintomo;
  final String causa;
  final String rimedio;

  factory ProblemaComune.fromJson(Map<String, dynamic> j) => ProblemaComune(
    sintomo: j['sintomo'] as String,
    causa: j['causa'] as String,
    rimedio: j['rimedio'] as String,
  );
}

List<String> _stringhe(Object? v) =>
    ((v as List?) ?? const []).map((e) => e as String).toList();
