import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/b_transaction.dart';

class TransactionService {
  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User belum login!");
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  Future<void> create(BTransaction transaction) async {
    await _db.add(transaction.toJson());
  }

  Stream<List<BTransaction>> getAllByUserId() {
    try {
      return _db.orderBy('dateTime', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return BTransaction.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<BTransaction>> getByWallet(String walletId) {
    try {
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
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> update(BTransaction transaction) async {
    await _db.doc(transaction.id).update(transaction.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
