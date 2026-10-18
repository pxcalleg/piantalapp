import 'motore_3d.dart';
import 'specie/ficus.dart';
import 'specie/ficus_bambino.dart';
import 'specie/fittonia.dart';
import 'specie/liquidambar.dart';
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
  'liquidambar': Liquidambar(),
  'ficus-bambino': FicusBambino(),
};
