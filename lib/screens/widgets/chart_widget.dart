import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Necesar pentru funcția min
import '../../utils/helpers.dart';

class ChartWidget extends StatelessWidget {
  final List<FlSpot> spotsA;
  final List<FlSpot> spotsB;
  final String nameA;
  final String nameB;

  const ChartWidget({
    super.key,
    required this.spotsA,
    required this.spotsB,
    required this.nameA,
    required this.nameB,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- LOGICA PENTRU AXE EGALE ---
    // Calculăm lungimea minimă comună pentru ca liniile să se termine în același punct
    int commonLength = min(spotsA.length, spotsB.length);
    
    // Tăiem ambele liste pentru a fi perfect egale
    List<FlSpot> finalSpotsA = spotsA.take(commonLength).toList();
    List<FlSpot> finalSpotsB = spotsB.take(commonLength).toList();

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
                  TextStyle(
                    color: barSpot.bar.color ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true, // Activăm liniile verticale pentru a vedea grid-ul zilelor
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.white10 : Colors.black12,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: isDark ? Colors.white10 : Colors.black12,
            strokeWidth: 1,
          ),
        ),

        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) => Text(
                "${value.toInt()}%",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),

          // AXA JOS: AFIȘĂM TOATE NUMERELE
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // Pas de 1 pentru a trece prin fiecare zi
              getTitlesWidget: (value, meta) {
                // Afișăm numărul pentru fiecare punct de pe axa X
                // value + 1 pentru a începe numărătoarea de la 1
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    "${value.toInt() + 1}",
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(show: false),

        // Folosim listele tăiate (finalSpots) pentru a garanta lungimea egală
        lineBarsData: [
          _buildLine(finalSpotsA, Colors.orange), 
          _buildLine(finalSpotsB, Colors.indigo),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}