import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_record.dart';

class ShoppingRecordService {
  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User belum login!");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shopping_records');
  }

  Future<void> create(ShoppingRecord record) async {
    await _db.add(record.toJson());
  }

  Stream<List<ShoppingRecord>> getAll() {
    try {
      return _db.orderBy('tanggal', descending: true).snapshots().map((
        snapshot,
      ) {
        return snapshot.docs.map((doc) {
          return ShoppingRecord.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Ambil semua catatan belanja milik satu akun anggaran tertentu
  Stream<List<ShoppingRecord>> getByBudgetAccount(String budgetAccountId) {
    try {
      return _db
          .where('budgetAccountId', isEqualTo: budgetAccountId)
          .orderBy('tanggal', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ShoppingRecord.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> update(ShoppingRecord record) async {
    await _db.doc(record.id).update(record.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
