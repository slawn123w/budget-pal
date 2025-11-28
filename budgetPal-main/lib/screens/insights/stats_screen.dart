import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/expense_chart.dart';
import '../../data/expense_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ExpenseProvider>(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Insights'),
          backgroundColor: Colors.blue[700],
          elevation: 0,
        ),
        backgroundColor: Colors.grey[100],
        body: ListView(
          children: const [
            SizedBox(height: 16),
            ExpenseChart(),
          ],
        ),
      ),
    );
  }
}
