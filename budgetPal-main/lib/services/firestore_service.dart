import 'package:budget_pal/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/category_budget.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentReference> addExpense(String userId, Expense expense) async {
    return await _db.collection('users').doc(userId)
      .collection('expenses').add(expense.toMap());
  }
  Future<DocumentReference> addUser(UserModel user) async {
    // Ensure the user document exists at users/{uid}
    final docRef = _db.collection('users').doc(user.id);
    await docRef.set(user.toMap(), SetOptions(merge: true));
    return docRef;
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return _db.collection('users').doc(userId)
      .collection('expenses')
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Expense.fromFirestore(doc)).toList());
  }

  // Budgets
  Future<void> setCategoryBudget(String userId, CategoryBudget budget) async {
    await _db.collection('users').doc(userId)
      .collection('budgets').doc(budget.category).set(budget.toMap());
  }

  Stream<List<CategoryBudget>> getCategoryBudgets(String userId) {
    return _db.collection('users').doc(userId)
      .collection('budgets')
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => CategoryBudget.fromMap(doc.data())).toList());
  }
}
