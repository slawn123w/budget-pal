import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/categories.dart';
import '../models/category_budget.dart';
import '../data/expense_provider.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final budgets = Provider.of<ExpenseProvider>(context, listen: false).budgets;
    for (final cat in kExpenseCategories) {
      final budget = budgets.firstWhere(
        (b) => b.category == cat,
        orElse: () => CategoryBudget(category: cat, amount: 0),
      );
      _controllers[cat] = TextEditingController(text: budget.amount > 0 ? budget.amount.toStringAsFixed(0) : '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveBudgets() async {
    setState(() => _loading = true);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    for (final cat in kExpenseCategories) {
      final text = _controllers[cat]?.text.trim() ?? '';
      final amount = double.tryParse(text) ?? 0;
      await provider.setCategoryBudget(CategoryBudget(category: cat, amount: amount));
    }
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budgets saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Category Budgets'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Set a monthly budget for each category. Leave blank for no budget.',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        ...kExpenseCategories.where((cat) => cat != 'Other').map((cat) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_rounded, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _controllers[cat],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Budget',
                                        prefixIcon: Icon(Icons.monetization_on_rounded, color: Colors.green[700]),
                                        prefixText: 'GHS ',
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _loading ? null : _saveBudgets,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Save Budgets', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        for (final c in _controllers.values) {
                                          c.clear();
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All budgets reset!')));
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Reset All', style: TextStyle(fontSize: 16, color: Colors.blue)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
