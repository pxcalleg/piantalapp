import 'motore_3d.dart';
import 'specie/ficus.dart';
import 'specie/fittonia.dart';
import 'specie/kalanchoe.dart';
import 'specie/orchidee.dart';
import 'specie/pothos.dart';
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
  'phalaenopsis': Falenopsis(),
  'dendrobium': Dendrobium(),
  'cymbidium': Cymbidium(),
  'stella-di-natale': StellaDiNatale(),
  'kalanchoe': Kalanchoe(),
};
