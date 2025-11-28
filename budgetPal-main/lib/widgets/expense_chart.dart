import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/expense_provider.dart';
import '../constants/categories.dart';

// Extension to darken a color for better contrast in tooltips
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class ExpenseChart extends StatefulWidget {
  const ExpenseChart({super.key});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  // Returns a color for each category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.blueAccent;
      case 'Entertainment':
        return Colors.purpleAccent;
      case 'Shopping':
        return Colors.greenAccent;
      case 'Transport':
        return Colors.orangeAccent;
      case 'Health':
        return Colors.redAccent;
      case 'Bills':
        return Colors.teal;
      case 'Education':
        return Colors.indigoAccent;
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all expenses from provider
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    final Map<String, double> categoryTotals = {};
    // Sum up expenses per category
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    // Sort categories by total spent, keep top 4, group rest as 'Other'
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(4).toList();
    final otherTotal = sortedEntries.skip(4).fold(0.0, (sum, e) => sum + e.value);
    final categories = [
      ...topEntries.map((e) => e.key),
      if (otherTotal > 0) 'Other',
    ];
    final values = [
      ...topEntries.map((e) => e.value),
      if (otherTotal > 0) otherTotal,
    ];
    // Assign a color to each category
    List<Color> chartColors = categories.map((cat) => _getCategoryColor(cat)).toList();
    // If no expenses, show message
    if (categories.isEmpty) {
      return const Center(child: Text('No expenses to display.'));
    }
    // Calculate total spent
    final total = values.fold(0.0, (a, b) => a + b);
    // Example budgets for each category (replace with your real data)
    final budgets = <String, double>{
      'Food': 500,
      'Entertainment': 300,
      'Shopping': 400,
      'Transport': 200,
      'Health': 250,
      'Bills': 350,
      'Education': 200,
      'Other': 150,
    };
    // For each category, get the budget (or fallback to at least the spent value or 100)
    final List<double> maxBars = [
      for (int i = 0; i < categories.length; i++)
        budgets[categories[i]] != null && budgets[categories[i]]! > values[i]
          ? budgets[categories[i]]!
          : (values[i] > 0 ? values[i] : 100),
    ];
    // Build the chart card
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'Expense Analytics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
               
                // Section title
                const Text('Breakdown by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                // Bar chart for category expenses vs. budget
                SizedBox(
                  height: 140, // Slightly taller for bolder bars
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: false, // Disable all touch/tooltip interaction
                        handleBuiltInTouches: false,
                        // No tooltip configuration
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // Show only the category name under each bar in a smaller font
                              final idx = value.toInt();
                              if (idx < 0 || idx >= categories.length) return const SizedBox();
                              final label = categories[idx];
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9, // Smaller font
                                    fontWeight: FontWeight.w500,
                                    color: chartColors[idx].darken(0.25),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            },
                            reservedSize: 22, // More space for full names
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      // Bar groups for each category
                      barGroups: [
                        for (int i = 0; i < values.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: values[i],
                                color: chartColors[i].withOpacity(0.85),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12), 
                                  topRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ), // Rounded bar ends
                                width: 22, // Wider bars for bolder look
                                gradient: LinearGradient(
                                  colors: [chartColors[i].withOpacity(0.95), chartColors[i].withOpacity(0.5)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                // Add subtle shadow for depth
                                rodStackItems: [
                                  BarChartRodStackItem(0, values[i], chartColors[i].withOpacity(0.18)),
                                ],
                                // Faint gray background for budget
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxBars[i],
                                  color: const Color.fromARGB(211, 133, 132, 132).withOpacity(0.13),
                                ),
                              ),
                            ],
                            // Remove showingTooltipIndicators to hide all value tips
                          ),
                        // (FL Chart doesn't support a direct marker, so we use the faint gray background as the cap)
                      ],
                      // Set maxY to the largest budget (with a little headroom)
                      maxY: maxBars.isNotEmpty ? maxBars.reduce((a, b) => a > b ? a : b) * 1.1 : 100,
                      groupsSpace: 18, // More space between bars
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 900),
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),
                ),
                // Info row below chart
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('You spent GHS ${total.toStringAsFixed(2)} in ${categories.length} categories',
                          style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black87, fontSize: 11)),
                      Text('Updated: Today', style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.w400, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Animated Pie Chart Widget
class AnimatedPieChart extends StatefulWidget {
  final List<String> categories;
  final List<double> values;
  final List<Color> chartColors;
  const AnimatedPieChart({super.key, required this.categories, required this.values, required this.chartColors});
  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}
class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin {
  double animValue = 0.0;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _controller.addListener(() {
      setState(() {
        animValue = _controller.value;
      });
    });
    _controller.forward();
  }
  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _controller.reset();
      _controller.forward();
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final total = widget.values.fold(0.0, (a, b) => a + b);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              startDegreeOffset: -90,
              sections: [
                for (int i = 0; i < widget.values.length; i++)
                  PieChartSectionData(
                    color: widget.chartColors[i],
                    value: widget.values[i] * animValue,
                    title: widget.values[i] == 0 || total == 0 ? '' : '${((widget.values[i] / total) * 100).toStringAsFixed(1)}%',
                    titleStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87),
                    radius: 48,
                    titlePositionPercentageOffset: 0.7,
                    showTitle: true,
                  ),
              ],
            ),
            swapAnimationDuration: const Duration(milliseconds: 900),
            swapAnimationCurve: Curves.easeInOutCubic,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Total', style: TextStyle(color: Colors.black54, fontSize: 11)),
            Text(
              'GHS ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                shadows: [Shadow(color: Colors.white24, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
