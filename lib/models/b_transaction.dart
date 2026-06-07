import 'package:cloud_firestore/cloud_firestore.dart';

class BTransaction {
  String? id;
  String? userId;
  String walletId;
  String categoryId;
  double amount;
  DateTime dateTime;
  String type; // 'INCOME' or 'EXPENSE'
  String? notes;

  BTransaction({
    this.id,
    this.userId,
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
      userId: json['userId'] ?? '',
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
      'userId': userId,
      'walletId': walletId,
      'categoryId': categoryId,
      'amount': amount,
      'dateTime': dateTime,
      'type': type,
      'notes': notes,
    };
  }
}
