import 'package:cloud_firestore/cloud_firestore.dart';

class BTransaction {
  String? id;
  String walletId;
  String categoryId;
  double amount;
  DateTime dateTime;
  String type; // 'INCOME' or 'EXPENSE'

  BTransaction({
    this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.dateTime,
    required this.type,
  });

  factory BTransaction.fromJson(Map<String, dynamic> json, String docId) {
    return BTransaction(
      id: docId,
      walletId: json['walletId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      dateTime: (json['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: json['type'] ?? 'EXPENSE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'categoryId': categoryId,
      'amount': amount,
      'dateTime': dateTime,
      'type': type,
    };
  }
}
