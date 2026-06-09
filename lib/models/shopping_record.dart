import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingRecord {
  String? id;
  DateTime tanggal;
  String budgetAccountId; // referensi ke Akun Anggaran
  double volume;
  String satuan;
  double jumlahTotal;
  String keterangan;
  String buktiPengeluaran; // URL atau nama file bukti

  ShoppingRecord({
    this.id,
    required this.tanggal,
    required this.budgetAccountId,
    required this.volume,
    required this.satuan,
    required this.jumlahTotal,
    required this.keterangan,
    required this.buktiPengeluaran,
  });

  factory ShoppingRecord.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;
    final dynamic raw = json['tanggal'];
    if (raw is Timestamp) {
      parsedDate = raw.toDate();
    } else if (raw is String) {
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ShoppingRecord(
      id: docId,
      tanggal: parsedDate,
      budgetAccountId: json['budgetAccountId'] ?? '',
      volume: (json['volume'] ?? 0.0).toDouble(),
      satuan: json['satuan'] ?? '',
      jumlahTotal: (json['jumlahTotal'] ?? 0.0).toDouble(),
      keterangan: json['keterangan'] ?? '',
      buktiPengeluaran: json['buktiPengeluaran'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': Timestamp.fromDate(tanggal),
      'budgetAccountId': budgetAccountId,
      'volume': volume,
      'satuan': satuan,
      'jumlahTotal': jumlahTotal,
      'keterangan': keterangan,
      'buktiPengeluaran': buktiPengeluaran,
    };
  }
}
