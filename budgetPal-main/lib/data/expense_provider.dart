import 'dart:developer';

import 'package:budget_pal/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category_budget.dart';
import '../services/firestore_service.dart';

// ExpenseProvider manages expenses and budgets, and communicates with Firestore
class ExpenseProvider with ChangeNotifier {
  // List of all expenses for the current user
  List<Expense> _expenses = [];
  bool _loading = false;

  // Public getter for expenses
  List<Expense> get expenses => _expenses;
  // Public getter for loading state
  bool get loading => _loading;

  // List of all category budgets for the current user
  List<CategoryBudget> _budgets = [];
  // Public getter for budgets
  List<CategoryBudget> get budgets => _budgets;

  // Fetches expenses for the current user from Firestore and updates the state
  Future<void> fetchExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log('No user signed in. Cannot fetch expenses.');
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      // Listen to the Firestore stream for real-time expense updates
      FirestoreService().getExpenses(user.uid).listen(
        (expenseList) {
          // Update local state with fetched expenses
          log('Fetched \\${expenseList.length} expenses from Firestore for user: \\${user.email ?? user.uid}');
          _expenses = expenseList;
          _loading = false;
          notifyListeners();
        },
        onError: (error) {
          // Handle errors from the Firestore stream
          _loading = false;
          log('Failed to fetch expenses for user: \\${user.email ?? user.uid} - \\${error}');
          notifyListeners();
        },
        onDone: () {
          // Called when the Firestore stream is closed
          _loading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      // Handle any exceptions thrown during setup
      _loading = false;
      log('Exception in fetchExpenses for user: \\${user.email ?? user.uid} - \\${e}');
      notifyListeners();
    }
  }

  // Adds a new expense for the current user, ensuring the user exists in Firestore
  Future<DocumentReference> addExpense(Expense expense) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      UserModel userModel = UserModel(
        id: user!.uid,
        name: user.displayName ?? 'No Name',
        email: user.email ?? '',
      );

      // Ensure user exists in Firestore, then add the expense
      DocumentReference docRef = await addUser(userModel, user);
      DocumentReference docRefExpense = await FirestoreService().addExpense(
        docRef.id,
        expense,
      );
      return docRefExpense;
    } catch (e) {
      log('Error adding expense: \\${e}');
      throw Exception('Failed to add expense: \\${e}');
    }
  }

  // Adds the user to Firestore if not already present
  Future<DocumentReference> addUser(UserModel user, User authuser) async {
    try {
      user.id = authuser.uid;
      DocumentReference docRef = await FirestoreService().addUser(user);
      return docRef;
    } catch (e) {
      throw Exception('Failed to add user: \\${e}');
    }
  }

  // Fetches all category budgets for the current user from Firestore
  Future<void> fetchBudgets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Listen to the Firestore stream for real-time budget updates
    FirestoreService().getCategoryBudgets(user.uid).listen((budgetList) {
      _budgets = budgetList;
      notifyListeners();
    });
  }

  // Sets a category budget for the current user in Firestore
  Future<void> setCategoryBudget(CategoryBudget budget) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().setCategoryBudget(user.uid, budget);
    // Optionally, fetch budgets again or rely on stream
  }
}
