import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/helpers.dart';
import '../../models/chart_data_model.dart';

class ChartWidget extends StatelessWidget {
  final List<FlSpot> spotsA;
  final List<FlSpot> spotsB;
  final String nameA;
  final String nameB;
  final AssetStats statsA; 
  final AssetStats statsB; 

  const ChartWidget({
    super.key,
    required this.spotsA,
    required this.spotsB,
    required this.nameA,
    required this.nameB,
    required this.statsA,
    required this.statsB,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    int commonLength = min(spotsA.length, spotsB.length);
    List<FlSpot> finalSpotsA = spotsA.take(commonLength).toList();
    List<FlSpot> finalSpotsB = spotsB.take(commonLength).toList();

    // Cine a performat mai bine?
    bool winnerA = statsA.performance > statsB.performance;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: isDark ? const Color(0xFF2E3542) : Colors.blueGrey.withOpacity(0.9),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  "${AppHelpers.formatNumber(barSpot.y)}%",
                  TextStyle(color: barSpot.bar.color ?? Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}%", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text("${value.toInt() + 1}", style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _buildLine(finalSpotsA, Colors.orange, winnerA, isDark),
          _buildLine(finalSpotsB, Colors.indigo, !winnerA, isDark),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color, bool isWinner, bool isDark) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: isWinner ? 5 : 3, // Mai groasă dacă e câștigător
      dotData: const FlDotData(show: false),
      // --- EFECTUL DE STRĂLUCIRE ---
      shadow: isWinner 
          ? Shadow(color: color.withOpacity(0.8), blurRadius: isDark ? 20 : 15) 
          : const Shadow(color: Colors.transparent, blurRadius: 0),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(isWinner ? 0.4 : 0.1), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}