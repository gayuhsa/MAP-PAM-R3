import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/b_transaction.dart';

class TransactionService {
  final CollectionReference _txDb = FirebaseFirestore.instance.collection(
    'transactions',
  );
  final CollectionReference _walletDb = FirebaseFirestore.instance.collection(
    'wallets',
  );

  Future<void> create(BTransaction transaction) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final walletRef = _walletDb.doc(transaction.walletId);
      final walletSnapshot = await tx.get(walletRef);

      if (!walletSnapshot.exists) {
        throw Exception("Wallet does not exist!");
      }

      final currentBalance =
          (walletSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      double newBalance = currentBalance.toDouble();
      if (transaction.type == "INCOME") {
        newBalance += transaction.amount;
      } else {
        newBalance -= transaction.amount;
      }

      final nextTxRef = _txDb.doc();

      tx.set(nextTxRef, transaction.toJson());
      tx.update(walletRef, {'balance': newBalance});
    });
  }

  Stream<List<BTransaction>> getAllByUserId() {
    return _txDb
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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

  Stream<List<BTransaction>> getByWallet(String walletId) {
    return _txDb
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

  Stream<QuerySnapshot<Object?>> getSnapshots() {
    return _txDb.snapshots();
  }

  Future<void> delete(BTransaction transaction) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final txRef = _txDb.doc(transaction.id);
      final walletRef = _walletDb.doc(transaction.walletId);
      final walletSnapshot = await tx.get(walletRef);

      if (!walletSnapshot.exists) {
        throw Exception("Wallet does not exist!");
      }

      final currentBalance =
          (walletSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      double newBalance = currentBalance.toDouble();
      if (transaction.type == "INCOME") {
        newBalance -= transaction.amount;
      } else {
        newBalance += transaction.amount;
      }

      tx.delete(txRef);
      tx.update(walletRef, {'balance': newBalance});
    });
  }
}
