import 'pianta.dart';

/// Scheda di un fungo, come definita in schema/fungo.schema.json. Ha solo
/// scopo divulgativo: non serve a stabilire se un fungo è commestibile.
class Fungo implements Scheda {
  const Fungo({
    required this.id,
    required this.stato,
    required this.nomeScientifico,
    required this.nomiComuni,
    required this.famiglia,
    required this.descrizione,
    required this.commestibilita,
    required this.habitat,
    required this.stagione,
    required this.caratteristiche,
    required this.fonti,
    required this.autori,
    required this.aggiornato,
    this.sinonimi = const [],
    this.noteCommestibilita,
    this.sosia = const [],
    this.curiosita,
    this.immagini = const [],
  });

  @override
  final String id;
  final String stato;
  final String nomeScientifico;
  final List<String> sinonimi;
  final String famiglia;
  final Map<String, List<String>> nomiComuni;
  final String descrizione;

  /// 'commestibile', 'commestibile_con_cautela', 'non_commestibile',
  /// 'tossico' o 'mortale'.
  final String commestibilita;
  final String? noteCommestibilita;
  final String habitat;

  /// Mesi in cui compare di solito.
  final List<int> stagione;
  final Caratteristiche caratteristiche;

  /// Specie con cui si confonde, soprattutto quelle tossiche.
  final List<Sosia> sosia;
  final String? curiosita;
  final List<Immagine> immagini;
  final List<String> fonti;
  final List<String> autori;
  @override
  final String aggiornato;

  /// Nome principale in italiano, o il nome scientifico se manca.
  String get nome => nomiComuni['it']?.first ?? nomeScientifico;

  /// Nome comune con il nome latino tra parentesi: "Porcino (Boletus edulis)".
  String get titolo => '$nome ($nomeScientifico)';

  bool get inBozza => stato != 'revisionata';

  factory Fungo.fromJson(Map<String, dynamic> j) => Fungo(
    id: j['id'] as String,
    stato: j['stato'] as String,
    nomeScientifico: j['nome_scientifico'] as String,
    sinonimi: _stringhe(j['sinonimi']),
    famiglia: j['famiglia'] as String,
    nomiComuni: (j['nomi_comuni'] as Map<String, dynamic>).map(
      (lingua, nomi) => MapEntry(lingua, _stringhe(nomi)),
    ),
    descrizione: j['descrizione'] as String,
    commestibilita: j['commestibilita'] as String,
    noteCommestibilita: j['note_commestibilita'] as String?,
    habitat: j['habitat'] as String,
    stagione: (j['stagione'] as List).map((m) => m as int).toList(),
    caratteristiche: Caratteristiche.fromJson(
      j['caratteristiche'] as Map<String, dynamic>,
    ),
    sosia: ((j['sosia'] as List?) ?? const [])
        .map((s) => Sosia.fromJson(s as Map<String, dynamic>))
        .toList(),
    curiosita: j['curiosita'] as String?,
    immagini: ((j['immagini'] as List?) ?? const [])
        .map((i) => Immagine.fromJson(i as Map<String, dynamic>))
        .toList(),
    fonti: _stringhe(j['fonti']),
    autori: _stringhe(j['autori']),
    aggiornato: j['aggiornato'] as String,
  );
}

class Caratteristiche {
  const Caratteristiche({
    required this.cappello,
    required this.sottoIlCappello,
    required this.gambo,
    required this.carne,
    this.sporata,
  });

  final String cappello;

  /// Lamelle, tubuli e pori, pliche o aculei.
  final String sottoIlCappello;
  final String gambo;
  final String carne;
  final String? sporata;

  factory Caratteristiche.fromJson(Map<String, dynamic> j) => Caratteristiche(
    cappello: j['cappello'] as String,
    sottoIlCappello: j['sotto_il_cappello'] as String,
    gambo: j['gambo'] as String,
    carne: j['carne'] as String,
    sporata: j['sporata'] as String?,
  );
}

class Sosia {
  const Sosia({
    required this.nome,
    required this.nomeScientifico,
    required this.commestibilita,
    required this.differenze,
  });

  final String nome;
  final String nomeScientifico;
  final String commestibilita;
  final String differenze;

  String get titolo => '$nome ($nomeScientifico)';

  factory Sosia.fromJson(Map<String, dynamic> j) => Sosia(
    nome: j['nome'] as String,
    nomeScientifico: j['nome_scientifico'] as String,
    commestibilita: j['commestibilita'] as String,
    differenze: j['differenze'] as String,
  );
}

List<String> _stringhe(Object? v) =>
    ((v as List?) ?? const []).map((e) => e as String).toList();
