import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/b_transaction.dart';

class TransactionService {
  final CollectionReference _db = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('transactions');

  Future<void> create(BTransaction transaction) async {
    await _db.add(transaction.toJson());
  }

  Stream<List<BTransaction>> getAllByUserId() {
    return _db.orderBy('dateTime', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return BTransaction.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Stream<List<BTransaction>> getByWallet(String walletId) {
    return _db
        .where('walletId', isEqualTo: walletId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BTransaction.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  Future<void> update(BTransaction transaction) async {
    await _db.doc(transaction.id).update(transaction.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
