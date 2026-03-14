import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MultiChartWidget extends StatelessWidget {
  final List<List<FlSpot>> allSpots;
  final List<String> assetNames;
  final List<Color> colors;

  const MultiChartWidget({super.key, required this.allSpots, required this.assetNames, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (allSpots.isEmpty || allSpots.any((list) => list.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    double globalMinX = allSpots.map((list) => list.first.x).reduce((a, b) => a < b ? a : b);
    double globalMaxX = allSpots.map((list) => list.last.x).reduce((a, b) => a > b ? a : b);
    const double twoDaysInMs = 2 * 24 * 60 * 60 * 1000;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)}%',
                  TextStyle(color: colors[spot.barIndex % colors.length], fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        minX: globalMinX,
        maxX: globalMaxX,
        gridData: FlGridData(show: true, verticalInterval: twoDaysInMs),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: twoDaysInMs,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 9)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 10)),
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),

        borderData: FlBorderData(
          show: false,
        ),

        lineBarsData: allSpots.asMap().entries.map((entry) {
          return LineChartBarData(
            spots: entry.value,
            isCurved: true,
            color: colors[entry.key % colors.length],
            barWidth: 3,
            dotData: const FlDotData(show: false),
          );
        }).toList(),
      ),
    );
  }
}