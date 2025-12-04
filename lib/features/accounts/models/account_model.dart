class AccountModel {
  final String id;
  final String name;
  final double balance;
  final String type;
  final String currency;
  final DateTime? createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.currency,
    this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      balance: _parseBalance(json['balance']),
      type: json['type'] ?? 'EFECTIVO',
      currency: json['currency'] ?? 'USD',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  static double _parseBalance(dynamic balance) {
    if (balance is int) {
      return balance.toDouble();
    } else if (balance is double) {
      return balance;
    } else if (balance is String) {
      return double.parse(balance);
    }
    return 0.0;
  }
}
