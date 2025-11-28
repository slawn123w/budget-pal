class CategoryBudget {
  final String category;
  final double amount;

  CategoryBudget({required this.category, required this.amount});

  Map<String, dynamic> toMap() => {
        'category': category,
        'amount': amount,
      };

  factory CategoryBudget.fromMap(Map<String, dynamic> map) => CategoryBudget(
        category: map['category'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
      );
}
