import 'package:fl_chart/fl_chart.dart';

class AppHelpers {
  // Metoda pentru normalizarea datelor pe grafic
  static List<FlSpot> normalizeData(List<dynamic> rawData) {
  if (rawData.isEmpty) return [];

  // Luăm prețul primei zile ca referință (punctul 0%)
  double firstPrice = double.parse(rawData.first['close'].toString());

  return rawData.map((data) {
    // Axa X: Timestamp-ul datei
    DateTime date = DateTime.parse(data['datetime'].toString());
    double x = date.millisecondsSinceEpoch.toDouble();

    // Axa Y: Diferența procentuală față de prima zi
    double currentPrice = double.parse(data['close'].toString());
    double y = ((currentPrice - firstPrice) / firstPrice) * 100;

    return FlSpot(x, y);
  }).toList();
}

  // Metoda Helper pentru rotunjirea la 2 zecimale (Globală)
  static String formatNumber(double value) {
    return value.toStringAsFixed(2);
  }
}