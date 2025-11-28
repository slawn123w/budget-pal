import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/expense_provider.dart';
import '../../constants/categories.dart';
import '../../models/category_budget.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  String _search = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Date (Newest)';

  void _showSetBudgetDialog(String category, double? currentBudget, Function(double) onSave) {
    final controller = TextEditingController(text: currentBudget?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Budget for $category'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Budget Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                onSave(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final budgets = expenseProvider.budgets;
    final expenses = expenseProvider.expenses.where((e) {
      final matchesSearch = _search.isEmpty ||
          e.title.toLowerCase().contains(_search.toLowerCase()) ||
          (e.note?.toLowerCase().contains(_search.toLowerCase()) ?? false);
      final matchesCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sorting
    expenses.sort((a, b) {
      if (_sortBy == 'Date (Newest)') {
        return b.date.compareTo(a.date);
      } else if (_sortBy == 'Date (Oldest)') {
        return a.date.compareTo(b.date);
      } else if (_sortBy == 'Amount (High-Low)') {
        return b.amount.compareTo(a.amount);
      } else {
        return a.amount.compareTo(b.amount);
      }
    });

    // Group by category
    final Map<String, List<dynamic>> grouped = {};
    for (var e in expenses) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }

    // Budget summary
    double totalBudget = budgets.fold(0, (sum, b) => sum + b.amount);
    double totalSpent = expenses.fold(0, (sum, e) => sum + e.amount);
    bool overBudget = totalSpent > totalBudget && totalBudget > 0;

    // Chart data
    List<BarChartGroupData> barGroups = budgets.map((b) {
      final spent = expenses.where((e) => e.category == b.category).fold(0.0, (sum, e) => sum + e.amount);
      return BarChartGroupData(
        x: kExpenseCategories.indexOf(b.category),
        barRods: [
          BarChartRodData(toY: spent, color: Colors.blue),
          BarChartRodData(toY: b.amount, color: Colors.grey.shade300, width: 8, borderRadius: BorderRadius.zero),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    Color getCategoryColor(String category) {
      switch (category) {
        case 'Food': return Colors.blue.shade100;
        case 'Entertainment': return Colors.purple.shade100;
        case 'Shopping': return Colors.green.shade100;
        case 'Transport': return Colors.orange.shade100;
        case 'Health': return Colors.red.shade100;
        case 'Bills': return Colors.teal.shade100;
        case 'Education': return Colors.indigo.shade100;
        case 'Investment': return Colors.amber.shade100;
        case 'Gifts': return Colors.pink.shade100;
        case 'Travel': return Colors.cyan.shade100;
        case 'Family': return Colors.brown.shade100;
        default: return Colors.grey.shade200;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (overBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warning: You are over your total budget!'), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Date (Newest)', child: Text('Date (Newest)')),
              const PopupMenuItem(value: 'Date (Oldest)', child: Text('Date (Oldest)')),
              const PopupMenuItem(value: 'Amount (High-Low)', child: Text('Amount (High-Low)')),
              const PopupMenuItem(value: 'Amount (Low-High)', child: Text('Amount (Low-High)')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(12),
            color: overBudget ? Colors.red.shade100 : Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('GHS ${totalBudget.toStringAsFixed(2)}'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Spent', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('GHS ${totalSpent.toStringAsFixed(2)}', style: TextStyle(color: overBudget ? Colors.red : Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Chart
          if (budgets.isNotEmpty)
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < kExpenseCategories.length) {
                            return Text(kExpenseCategories[idx], style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == 'All',
                    onSelected: (_) => setState(() => _selectedCategory = 'All'),
                  ),
                ),
                ...kExpenseCategories.map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Row(
                      children: [
                        Text(cat),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 16),
                          onPressed: () {
                            final currentBudget = budgets.firstWhere(
                              (b) => b.category == cat,
                              orElse: () => CategoryBudget(category: cat, amount: 0),
                            ).amount;
                            _showSetBudgetDialog(cat, currentBudget, (val) async {
                              await expenseProvider.setCategoryBudget(CategoryBudget(category: cat, amount: val));
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Grouped List
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses found.'))
                : ListView(
                    children: grouped.entries.map((entry) {
                      final cat = entry.key;
                      final catExpenses = entry.value;
                      final catBudget = budgets.firstWhere(
                        (b) => b.category == cat,
                        orElse: () => CategoryBudget(category: cat, amount: 0),
                      ).amount;
                      final catSpent = catExpenses.fold(0.0, (sum, e) => sum + e.amount);
                      final isOverCatBudget = catBudget > 0 && catSpent > catBudget;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (catBudget > 0)
                                  Text('Budget: GHS ${catBudget.toStringAsFixed(2)}', style: TextStyle(color: isOverCatBudget ? Colors.red : Colors.black)),
                                if (isOverCatBudget)
                                  const Icon(Icons.warning, color: Colors.red, size: 18),
                              ],
                            ),
                          ),
                          ...catExpenses.map<Widget>((e) => Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: getCategoryColor(e.category),
                                    width: 8,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${e.category} • ${e.date.toLocal().toString().split(' ')[0]}'),
                                    if (e.note != null && e.note!.isNotEmpty)
                                      Text(e.note!, style: const TextStyle(color: Colors.black54)),
                                  ],
                                ),
                                trailing: Text('GHS ${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
