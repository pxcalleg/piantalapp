import 'package:flutter/widgets.dart';

import 'pothos_3d.dart';
import 'stato_pianta.dart';

typedef CostruttorePittore = CustomPainter Function(
  StatoPianta stato,
  double rotazione,
  double luce,
);

/// Piante che hanno già un modello visuale interattivo, per id della scheda.
final Map<String, CostruttorePittore> modelliVisuali = {
  'pothos': (stato, rotazione, luce) =>
      PothosPainter(stato: stato, rotazione: rotazione, luce: luce),
};
