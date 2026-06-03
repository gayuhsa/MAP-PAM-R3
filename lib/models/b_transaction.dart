import 'package:cloud_firestore/cloud_firestore.dart';

class BTransaction {
  final String id;
  final String walletId;
  final String categoryId;
  final double amount;
  final DateTime dateTime;
  final String type; // 'INCOME' or 'EXPENSE'
  final String? notes;

  BTransaction({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.dateTime,
    required this.type,
    this.notes,
  });

  factory BTransaction.fromJson(Map<String, dynamic> json, String docId) {
    return BTransaction(
      id: docId,
      walletId: json['walletId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      dateTime: (json['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: json['type'] ?? 'EXPENSE',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'categoryId': categoryId,
      'amount': amount,
      'dateTime': dateTime,
      'type': type,
      'notes': notes,
    };
  }
}
