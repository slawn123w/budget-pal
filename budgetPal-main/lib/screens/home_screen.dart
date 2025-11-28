import 'package:budget_pal/models/category_budget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/mono_service.dart';
import '../models/mono_model.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';
import '../data/expense_provider.dart';
import 'expense_screen/add_expense.dart';
import '../constants/categories.dart';
import 'budget_settings_screen.dart';
import 'expense_screen/all_expenses_screen.dart';
import '../widgets/expense_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MonoAccount? _account;
  bool _loadingAccount = false;

  Future<String> _getFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null && doc.data()!['firstName'] != null) {
      return doc.data()!['firstName'];
    }
    return user.displayName?.split(' ').first ?? user.email?.split('@').first ?? '';
  }

  void _connectMono(BuildContext context) async {
    MonoService.launchMonoConnect(context, (code) async {
      setState(() => _loadingAccount = true);
      final token = await MonoApiService.exchangeCodeForToken(code);
      if (token != null) {
        final accountsJson = await MonoApiService.getAccounts(token);
        if (accountsJson != null && accountsJson['accounts'] != null && accountsJson['accounts'] is List && accountsJson['accounts'].isNotEmpty) {
          setState(() {
            _account = MonoAccount.fromJson(accountsJson['accounts'][0]);
            _loadingAccount = false;
          });
        } else {
          setState(() => _loadingAccount = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No accounts found.')));
        }
      } else {
        setState(() => _loadingAccount = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mono connection failed.')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    // Debug print for current user UID 
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('Current user UID: \\${user?.uid}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If there are no expenses and not currently loading, fetch expenses
      if (expenseProvider.expenses.isEmpty && !expenseProvider.loading) {
        expenseProvider.fetchExpenses();
      }
      // If there are no budgets, fetch budgets
      if (expenseProvider.budgets.isEmpty) {
        expenseProvider.fetchBudgets();
      }
    });

    String getGreeting() {
      // Returns a greeting string based on the current time of day
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      return 'Good evening';
    }
    return Scaffold(
      drawer: _AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: FutureBuilder<String>(
          future: _getFirstName(),
          builder: (context, snapshot) {
            final name = snapshot.data ?? '';
            return Text(
              name.isNotEmpty
                  ? 'Hi $name\n${getGreeting()} 👋'
                  : 'Hi\n${getGreeting()} 👋',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black54),
            onPressed: () {},
          ),
        ],
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[100],
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No user signed in. Please log in to fetch expenses.', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Balance',
                                style: TextStyle(color: Colors.black54, fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              if (_loadingAccount)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else if (_account != null)
                                Text(
                                  'GHS ${_account!.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                )
                              else
                                const Text(
                                  'GHS 0.00',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              if (_account != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${_account!.bankName} - ${_account!.accountNumber}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loadingAccount
                                ? null
                                : () => _connectMono(context), // Connects to Mono API
                            child: Text(_account == null ? '+ Add Wallet' : 'Refresh',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Category Cards
                    SizedBox(
                      height: 130,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final cat in kExpenseCategories)
                              if (cat != 'Other') ...[
                                _buildCategoryCard(cat, _getCategoryColor(cat), expenseProvider),
                                const SizedBox(width: 12),
                              ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recent Expenses
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigates to the All Expenses screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AllExpensesScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Manual fetch button for debugging
                       
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (expenseProvider.loading)
                      const Center(child: CircularProgressIndicator())
                    else if (expenseProvider.expenses.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No recent expenses found ', style: const TextStyle(color: Colors.black54)),
                          
                        ],
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenseProvider.expenses.length > 3 ? 3 : expenseProvider.expenses.length,
                        itemBuilder: (context, i) {
                          final e = expenseProvider.expenses[i];
                          return ListTile(
                            title: Text(e.title),
                            subtitle: Text('${e.category} • ${e.date.toLocal().toString().split(' ')[0]}'),
                            trailing: Text('GHS ${e.amount.toStringAsFixed(2)}'),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    // Spending Chart Placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spending Chart',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Navigates to the Add Expense screen
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                            );
                          },
                          child:  Text('+ Add Expense',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    const ExpenseChart(),
                  ],
                ),
              ),
            ),
    );
  }

  // Builds a category card showing budget and spending progress for a category
  Widget _buildCategoryCard(String category, Color color, ExpenseProvider provider) {
    final categoryExpenses = provider.expenses.where((e) => e.category == category).toList();
    final total = categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final userBudget = provider.budgets.firstWhere(
      (b) => b.category == category,
      orElse: () => CategoryBudget(category: category, amount: 0),
    );
    final budget = userBudget.amount ?? 0;
    final percent = budget > 0 ? (total / budget).clamp(0, 1) : 0.0;
    final overBudget = budget > 0 && total > budget;
    return _CategoryCard(
      label: category,
      amount: budget > 0 ? 'GHS ${total.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)}' : 'GHS ${total.toStringAsFixed(0)}',
      percent: percent.toDouble(),
      color: overBudget ? Colors.red : color,
    );
  }

  // Returns a color for each category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.green;
      case 'Transport':
        return Colors.orange;
      case 'Health':
        return Colors.red;
      case 'Bills':
        return Colors.teal;
      case 'Education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// Drawer widget for navigation
class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Modern user profile header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kaylon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('${user?.email ??""}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(Icons.home_rounded, 'Home', () {
              Navigator.of(context).pop();
            }),
            _drawerItem(Icons.receipt_long_rounded, 'All Expenses', () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllExpensesScreen()));
            }),
            _drawerItem(Icons.account_balance_wallet_rounded, 'Budgets', () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetSettingsScreen()));
            }),
            _drawerItem(Icons.bar_chart_rounded, 'Analytics', () {}),
            _drawerItem(Icons.account_balance_rounded, 'Wallets/Accounts', () {}),
            _drawerItem(Icons.settings_rounded, 'Settings', () {}),
            const Divider(),
            _drawerItem(Icons.help_outline_rounded, 'Help/Support', () {}),
            _drawerItem(Icons.logout_rounded, 'Logout', () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue[700]),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          hoverColor: Colors.blue.withOpacity(0.08),
        ),
      ),
    );
  }
}

// Category card widget
class _CategoryCard extends StatelessWidget {
  final String label;
  final String amount;
  final double percent;
  final Color color;

  const _CategoryCard({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
