import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../models/b_transaction.dart';

class TransactionService {
  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User belum login!');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  CollectionReference get _walletDb {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User belum login!');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallets');
  }

  double _computeDelta(String type, double amount) {
    return type.toUpperCase() == 'INCOME' ? amount : -amount;
  }

  Future<DocumentReference> create(BTransaction transaction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (kDebugMode) {
      debugPrint('Firestore Creating Transaction for User: ${user?.uid}');
    }
    final docRef = await _db.add(transaction.toJson());
    if (kDebugMode) {
      debugPrint(
        'Firestore Created Transaction Document: ${docRef.id} at path: ${docRef.path}',
      );
    }
    return docRef;
  }

  Future<DocumentReference> createWithWalletAdjustment(
    BTransaction transaction,
  ) async {
    if (kDebugMode) {
      print(
        'WARNING: Memulai pembuatan transaksi baru dan penyesuaian saldo dompet.',
      );
    }
    final walletRef = _walletDb.doc(transaction.walletId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final newDocRef = _db.doc();
      tx.set(newDocRef, transaction.toJson());
      tx.update(walletRef, {
        'balance': FieldValue.increment(
          _computeDelta(transaction.type, transaction.amount),
        ),
      });
      return newDocRef;
    });
  }

  Future<BTransaction?> getById(String id) async {
    if (id.isEmpty) return null;
    final doc = await _db.doc(id).get();
    if (!doc.exists) return null;
    return BTransaction.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Stream<List<BTransaction>> getAllByUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error('User belum login!');
    }
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error('User belum login!');
    }
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
    if (transaction.id == null || transaction.id!.isEmpty) {
      throw Exception('ID transaksi tidak valid');
    }
    await _db.doc(transaction.id).update(transaction.toJson());
  }

  Future<void> updateWithWalletAdjustment(
    BTransaction oldTransaction,
    BTransaction newTransaction,
  ) async {
    if (oldTransaction.id == null || oldTransaction.id!.isEmpty) {
      throw Exception('ID transaksi tidak valid');
    }

    if (kDebugMode) {
      debugPrint('WARNING: Memulai pembaruan transaksi ${oldTransaction.id}.');
    }
    final txRef = _db.doc(oldTransaction.id!);
    final oldDelta = _computeDelta(oldTransaction.type, oldTransaction.amount);
    final newDelta = _computeDelta(newTransaction.type, newTransaction.amount);
    final oldWalletRef = _walletDb.doc(oldTransaction.walletId);
    final newWalletRef = _walletDb.doc(newTransaction.walletId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(txRef);
      if (!snapshot.exists) {
        throw Exception('Transaksi tidak ditemukan');
      }
      tx.update(txRef, newTransaction.toJson());

      if (oldTransaction.walletId == newTransaction.walletId) {
        tx.update(oldWalletRef, {
          'balance': FieldValue.increment(newDelta - oldDelta),
        });
      } else {
        tx.update(oldWalletRef, {'balance': FieldValue.increment(-oldDelta)});
        tx.update(newWalletRef, {'balance': FieldValue.increment(newDelta)});
      }
    });
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  Future<void> deleteWithWalletAdjustment(BTransaction transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      throw Exception('ID transaksi tidak valid');
    }

    if (kDebugMode) {
      debugPrint('WARNING: Memulai penghapusan transaksi ${transaction.id}.');
    }
    final txRef = _db.doc(transaction.id!);
    final walletRef = _walletDb.doc(transaction.walletId);
    final delta = _computeDelta(transaction.type, transaction.amount);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(txRef);
      if (!snapshot.exists) {
        throw Exception('Transaksi tidak ditemukan');
      }
      tx.delete(txRef);
      tx.update(walletRef, {'balance': FieldValue.increment(-delta)});
    });
  }
}
