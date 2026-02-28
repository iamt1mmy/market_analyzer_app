import 'package:share_plus/share_plus.dart';
import '../models/chart_data_model.dart';

class ShareService {
  static void shareAnalysis({
    required String nameA,
    required String nameB,
    required AssetStats statsA,
    required AssetStats statsB,
    required String currency,
  }) {
    final String winner = statsA.performance > statsB.performance ? nameA : nameB;
    final double diff = (statsA.performance - statsB.performance).abs();

    final String message = '''
📊 Raport de Analiză Financiară:
⚔️ $nameA vs $nameB

📈 Evoluție $nameA: ${statsA.performance.toStringAsFixed(2)}%
📉 Evoluție $nameB: ${statsB.performance.toStringAsFixed(2)}%

🏆 Rezultat: $winner a dominat această perioadă cu o diferență de ${diff.toStringAsFixed(2)}%
💰 Calcul efectuat în moneda: $currency

Analiză generată cu Market Analyzer Pro
''';

    Share.share(message);
  }
}