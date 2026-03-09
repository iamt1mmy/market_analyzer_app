import 'package:flutter/material.dart'; // NECESAR pentru DateTimeRange
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; 
import '../models/chart_data_model.dart';
import '../utils/helpers.dart';

class ShareService {
  static void shareAnalysis({
    required String nameA,
    required String nameB,
    required AssetStats statsA,
    required AssetStats statsB,
    required String currency,
    required double rate,
    required DateTimeRange? range, // Acum clasa va fi recunoscută
  }) {
    // 1. Data și ora generării raportului
    final String nowStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // 2. Formatarea intervalului selectat de utilizator
    String rangeStr = "Nespecificat";
    if (range != null) {
      final String startStr = DateFormat('dd/MM/yyyy').format(range.start);
      final String endStr = DateFormat('dd/MM/yyyy').format(range.end);
      rangeStr = "$startStr - $endStr";
    }

    // 3. Logică pentru determinarea câștigătorului
    final bool isWinnerA = statsA.performance > statsB.performance;
    final String winnerName = isWinnerA ? nameA : nameB;

    // 4. Construirea mesajului final
    final String message = '''
📊 RAPORT FINANCIAR: MARKET ANALYZER PRO
----------------------------------------
🗓️ Generat la: $nowStr
⏱️ Perioada analizată: $rangeStr
💰 Moneda: $currency

⚔️ REZULTATE DUEL:
----------------------------------------
🚀 $nameA:
   • Randament: ${AppHelpers.formatNumber(statsA.performance)}%
   • Start: ${AppHelpers.formatNumber(statsA.startPrice * rate)} $currency
   • Final: ${AppHelpers.formatNumber(statsA.endPrice * rate)} $currency

📉 $nameB:
   • Randament: ${AppHelpers.formatNumber(statsB.performance)}%
   • Start: ${AppHelpers.formatNumber(statsB.startPrice * rate)} $currency
   • Final: ${AppHelpers.formatNumber(statsB.endPrice * rate)} $currency

----------------------------------------
🏆 CÂȘTIGĂTOR: $winnerName
----------------------------------------
Trimis din aplicația Market Analyzer Pro.
''';

    // 5. Acțiunea de Share
    Share.share(message, subject: 'Analiză $nameA vs $nameB');
  }
}