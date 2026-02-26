class WalletTransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type; // credit, debit
  final String? description;
  final DateTime? createdAt;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    this.createdAt,
  });

  factory WalletTransactionModel.fromMap(Map<String, dynamic> map) {
    return WalletTransactionModel(
      id: map['id'],
      userId: map['user_id'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      description: map['description'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
