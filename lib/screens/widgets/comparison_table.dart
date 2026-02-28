import 'package:flutter/material.dart';
import '../../models/chart_data_model.dart';
import '../../utils/formatter.dart';

class ComparisonTable extends StatelessWidget {
  final AssetStats statsA, statsB;
  final String nameA, nameB, currency;
  final double rate;

  const ComparisonTable({super.key, required this.statsA, required this.statsB, required this.nameA, required this.nameB, required this.currency, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          _row("Metrică", nameA, nameB, h: true),
          const Divider(),
          _row("Start", AppFormatter.formatCurrency(statsA.startPrice * rate, currency), AppFormatter.formatCurrency(statsB.startPrice * rate, currency)),
          _row("Final", AppFormatter.formatCurrency(statsA.endPrice * rate, currency), AppFormatter.formatCurrency(statsB.endPrice * rate, currency)),
          _row("Profit %", "${statsA.performance.toStringAsFixed(2)}%", "${statsB.performance.toStringAsFixed(2)}%", p: true),
        ]),
      ),
    );
  }

  Widget _row(String l, String a, String b, {bool h = false, bool p = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Expanded(child: Text(l, style: TextStyle(fontWeight: h ? FontWeight.bold : FontWeight.normal))),
      Expanded(child: Text(a, style: TextStyle(color: p && !h ? (statsA.performance >= 0 ? Colors.green : Colors.red) : null))),
      Expanded(child: Text(b, style: TextStyle(color: p && !h ? (statsB.performance >= 0 ? Colors.green : Colors.red) : null))),
    ]),
  );
}