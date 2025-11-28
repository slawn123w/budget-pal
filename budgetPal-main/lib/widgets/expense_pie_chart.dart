import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final List<String> categories;
  final List<double> values;
  final List<Color> chartColors;
  const ExpensePieChart({super.key, required this.categories, required this.values, required this.chartColors});

  @override
  Widget build(BuildContext context) {
    final total = values.fold(0.0, (a, b) => a + b);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              startDegreeOffset: -90,
              sections: [
                for (int i = 0; i < values.length; i++)
                  PieChartSectionData(
                    color: chartColors[i],
                    value: values[i],
                    title: values[i] == 0 || total == 0 ? '' : '${((values[i] / total) * 100).toStringAsFixed(1)}%',
                    titleStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                    radius: 60,
                    titlePositionPercentageOffset: 0.7,
                    showTitle: true,
                  ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Total', style: TextStyle(color: Colors.black54, fontSize: 13)),
            Text(
              'GHS ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [Shadow(color: Colors.white24, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
