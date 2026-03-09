import 'package:fl_chart/fl_chart.dart';

class AppHelpers {
  // Metoda pentru normalizarea datelor pe grafic
  static List<FlSpot> normalizeData(List<dynamic> raw) {
    if (raw.isEmpty) return [];
    double base = double.parse(raw.first['close']);
    return List.generate(raw.length, (i) {
      double current = double.parse(raw[i]['close']);
      return FlSpot(i.toDouble(), ((current - base) / base) * 100);
    });
  }

  // Metoda Helper pentru rotunjirea la 2 zecimale (Globală)
  static String formatNumber(double value) {
    return value.toStringAsFixed(2);
  }
}