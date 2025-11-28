import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../data/expense_provider.dart';
import '../../constants/categories.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  String _category = '';
  String? _note;
  bool _loading = false;

  String _selectedCategory = kExpenseCategories[0];
  String _customCategory = '';

  void _submit() async {
    log("this is the state of loading: $_loading");
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    log("this is the state of loading: $_loading");
    final expense = Expense(
      id: '',
      title: _title,
      amount: _amount,
      date: _date,
      category: _category,
      note: _note,
    );
    try {
      await Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

      if (!mounted) return;
      setState(() => _loading = false);
      log("this is the state of loading: $_loading");
      print(_loading);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false); // Navigate to home and clear stack
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      log("Failed to add expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.title_rounded, color: Colors.blue[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                          onSaved: (v) => _title = v!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.attach_money, color: Colors.green[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid amount' : null,
                          onSaved: (v) => _amount = double.parse(v!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category, color: Colors.purple[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: kExpenseCategories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val!;
                            });
                          },
                          onSaved: (val) {
                            if (val == 'Other' && _customCategory.isNotEmpty) {
                              _category = _customCategory.trim();
                            } else {
                              _category = val!.trim();
                            }
                          },
                        ),
                        if (_selectedCategory == 'Other') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Custom Category',
                              prefixIcon: Icon(Icons.edit, color: Colors.orange[700]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (_selectedCategory == 'Other' && (v == null || v.trim().isEmpty)) {
                                return 'Enter a custom category';
                              }
                              return null;
                            },
                            onChanged: (v) => _customCategory = v.trim(),
                            onSaved: (v) => _customCategory = v?.trim() ?? '',
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Note (optional)',
                            prefixIcon: Icon(Icons.note_alt, color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onSaved: (v) => _note = v,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
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
                                : const Text('Add Expense', style: TextStyle(fontSize: 16)),
                          ),
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
