import 'motore_3d.dart';
import 'specie/aloe.dart';
import 'specie/cactus.dart';
import 'specie/crassula.dart';
import 'specie/echeveria.dart';
import 'specie/ficus.dart';
import 'specie/fittonia.dart';
import 'specie/haworthia.dart';
import 'specie/pothos.dart';
import 'specie/sansevieria.dart';
import 'specie/spatifillo.dart';

/// Piante che hanno un modello visuale interattivo, per id della scheda.
const Map<String, Specie> modelliVisuali = {
  'pothos': Pothos(),
  'ficus-benjamina': FicusBenjamina(),
  'ficus-elastica': FicusRobusta(),
  'ficus-lyrata': FicusLyrata(),
  'sansevieria': Sansevieria(),
  'fittonia': Fittonia(),
  'spatifillo': Spatifillo(),
  'aloe-vera': AloeVera(),
  'crassula': Crassula(),
  'echeveria': Echeveria(),
  'haworthia': Haworthia(),
  'mammillaria': Mammillaria(),
  'opuntia': Opuntia(),
};
