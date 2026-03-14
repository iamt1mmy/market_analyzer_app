import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/chart_data_model.dart';

class ShareService {
  static void shareMultiAnalysis({
    required List<String> names,
    required List<AssetStats> stats,
    required String currency,
    required double rate,
    DateTimeRange? range,
  }) {
    String report = "📊 ANALIZĂ COMPARATIVĂ PIAȚĂ\n";
    if (range != null) {
      report += "Perioada: ${range.start.day}.${range.start.month} - ${range.end.day}.${range.end.month}.${range.end.year}\n\n";
    }

    for (int i = 0; i < names.length; i++) {
      if (i >= stats.length) break;
      final s = stats[i];
      report += "🔹 ${names[i]}\n";
      report += "   Preț Actual: ${(s.endPrice * rate).toStringAsFixed(2)} $currency\n";
      report += "   Evoluție: ${s.performance.toStringAsFixed(2)}%\n";
      report += "   Interval: ${(s.minPrice * rate).toStringAsFixed(2)} - ${(s.maxPrice * rate).toStringAsFixed(2)}\n\n";
    }

    report += "Generat de Market Analyzer Pro 🚀";
    Share.share(report);
  }
}