import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final List<FlSpot> spotsA;
  final List<FlSpot> spotsB;
  final String nameA;
  final String nameB;

  const ChartWidget({super.key, required this.spotsA, required this.spotsB, required this.nameA, required this.nameB});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _indicator(nameA, Colors.orange),
              const SizedBox(width: 20),
              _indicator(nameB, Colors.indigo),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(LineChartData(
              lineBarsData: [
                _bar(spotsA, Colors.orange),
                _bar(spotsB, Colors.indigo),
              ],
              titlesData: const FlTitlesData(topTitles: AxisTitles(), rightTitles: AxisTitles()),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            )),
          ),
        ],
      ),
    );
  }

  LineChartBarData _bar(List<FlSpot> s, Color c) => LineChartBarData(
    spots: s, color: c, barWidth: 4, isCurved: true, dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: true, color: c.withOpacity(0.1)),
  );

  Widget _indicator(String t, Color c) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  ]);
}