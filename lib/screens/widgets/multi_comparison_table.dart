import 'package:flutter/material.dart';
import '../../models/chart_data_model.dart';

class MultiComparisonTable extends StatelessWidget {
  final List<AssetStats> allStats;
  final List<String> names;
  final String currency;
  final double rate;
  final List<Color> colors;

  const MultiComparisonTable({
    super.key, 
    required this.allStats, 
    required this.names, 
    required this.currency, 
    required this.rate, 
    required this.colors
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: DataTable(
        columnSpacing: 15,
        horizontalMargin: 15,
        headingRowHeight: 45,
        dataRowMaxHeight: 50,
        columns: const [
          DataColumn(label: Text('ACTIV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('START', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('FINAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('EVOLUȚIE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
        ],
        rows: allStats.asMap().entries.map((entry) {
          int idx = entry.key;
          
          // Siguranță pentru sincronizarea indexului
          if (idx >= names.length) return const DataRow(cells: [DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]);

          final s = entry.value;
          final perf = s.performance;
          
          return DataRow(cells: [
            // Coloana 1: Activ (Simbol + Culoare)
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors[idx % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                names[idx].contains('(') ? names[idx].split('(')[1].replaceAll(')', '') : names[idx], 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ])),
            
            // Coloana 2: Preț Initial (startPrice)
            DataCell(Text(
              '${(s.startPrice * rate).toStringAsFixed(3)} $currency', 
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)
            )),
            
            // Coloana 3: Preț Final (endPrice)
            DataCell(Text(
              '${(s.endPrice * rate).toStringAsFixed(3)} $currency', 
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)
            )),
            
            // Coloana 4: Evoluție (performance)
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (perf >= 0 ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${perf >= 0 ? "+" : ""}${perf.toStringAsFixed(2)}%', 
                style: TextStyle(
                  color: perf >= 0 ? Colors.green : Colors.redAccent, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 11
                ),
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}