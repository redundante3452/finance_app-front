class TransactionModel {
  final String id;
  final double amount;
  final String type; // INCOME or EXPENSE
  final String categoryId; // UUID
  final String accountId; // UUID
  final DateTime date;
  final String? description;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] is String 
          ? double.parse(json['amount']) 
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'EXPENSE',
      categoryId: json['categoryId']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
