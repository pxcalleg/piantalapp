import 'motore_3d.dart';
import 'specie/aloe.dart';
import 'specie/cactus.dart';
import 'specie/crassula.dart';
import 'specie/echeveria.dart';
import 'specie/ficus.dart';
import 'specie/ficus_bambino.dart';
import 'specie/fittonia.dart';
import 'specie/liquidambar.dart';
import 'specie/ortensia.dart';
import 'specie/kalanchoe.dart';
import 'specie/orchidee.dart';
import 'specie/haworthia.dart';
import 'specie/pothos.dart';
import 'specie/rosa.dart';
import 'specie/sansevieria.dart';
import 'specie/spatifillo.dart';
import 'specie/stella_di_natale.dart';

/// Piante che hanno un modello visuale interattivo, per id della scheda.
const Map<String, Specie> modelliVisuali = {
  'pothos': Pothos(),
  'ficus-benjamina': FicusBenjamina(),
  'ficus-elastica': FicusRobusta(),
  'ficus-lyrata': FicusLyrata(),
  'sansevieria': Sansevieria(),
  'fittonia': Fittonia(),
  'spatifillo': Spatifillo(),
  'liquidambar': Liquidambar(),
  'ficus-bambino': FicusBambino(),
  'rosa-tea-ibrida': rosaTeaIbrida,
  'rosa-floribunda': rosaFloribunda,
  'rosa-rampicante': rosaRampicante,
  'rosa-inglese': rosaInglese,
  'rosa-miniatura': rosaMiniatura,
  'ortensia': Ortensia(),
  'phalaenopsis': Falenopsis(),
  'dendrobium': Dendrobium(),
  'cymbidium': Cymbidium(),
  'stella-di-natale': StellaDiNatale(),
  'kalanchoe': Kalanchoe(),
  'aloe-vera': AloeVera(),
  'crassula': Crassula(),
  'echeveria': Echeveria(),
  'haworthia': Haworthia(),
  'mammillaria': Mammillaria(),
  'opuntia': Opuntia(),
};
