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

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory BTransaction.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;
    final dynamic rawDateTime = json['dateTime'];
    if (rawDateTime is Timestamp) {
      parsedDate = rawDateTime.toDate();
    } else if (rawDateTime is String) {
      parsedDate = DateTime.tryParse(rawDateTime) ?? DateTime.now();
    } else if (rawDateTime is Map) {
      try {
        parsedDate = DateTime(
          rawDateTime['year'] ?? 2026,
          rawDateTime['month'] ?? 1,
          rawDateTime['day'] ?? 1,
          rawDateTime['hour'] ?? 0,
          rawDateTime['minute'] ?? 0,
          rawDateTime['second'] ?? 0,
        );
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return BTransaction(
      id: docId,
      walletId: json['walletId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: _parseDouble(json['amount']),
      dateTime: parsedDate,
      type: (json['type'] as String?)?.toUpperCase() ?? 'EXPENSE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'categoryId': categoryId,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type,
    };
  }
}
