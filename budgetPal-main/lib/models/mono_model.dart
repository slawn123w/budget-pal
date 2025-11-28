class MonoAccount {
  final String id;
  final String name;
  final String type;
  final String bankName;
  final String accountNumber;
  final double balance;

  MonoAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.bankName,
    required this.accountNumber,
    required this.balance,
  });

  factory MonoAccount.fromJson(Map<String, dynamic> json) {
    return MonoAccount(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      bankName: json['institution']?['name'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
    );
  }
}
