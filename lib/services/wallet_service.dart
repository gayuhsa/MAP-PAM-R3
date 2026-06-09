import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:rxdart/rxdart.dart';
import '../models/wallet.dart';
import 'transaction_service.dart';

class WalletService {
  static const String _defaultWalletId = '_default_wallet';

  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User belum login!");
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallets');
  }

  Future<void> create(Wallet wallet) async {
    if (kDebugMode) {
      debugPrint('WARNING: Memulai pembuatan dompet baru.');
    }
    await _db.add(wallet.toJson());
  }

  Stream<List<Wallet>> getAllByUserId() {
    return FirebaseAuth.instance.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Wallet.fromJson(doc.data(), doc.id))
                .toList(),
          );
    });
  }

  Future<void> update(Wallet wallet) async {
    if (kDebugMode) {
      debugPrint('WARNING: Memulai pembaruan dompet ${wallet.id}.');
    }
    await _db.doc(wallet.id).update(wallet.toJson());
  }

  Future<void> delete(String id) async {
    if (kDebugMode) {
      debugPrint('WARNING: Memulai penghapusan dompet $id.');
    }
    await _db.doc(id).delete();
  }

  Future<void> deleteWithTransactionHandling(
    String id, {
    bool deleteTransactions = false,
    bool reassignTransactionsToDefault = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'WARNING: Memulai penghapusan dompet $id dengan penanganan transaksi.',
      );
    }

    if (deleteTransactions && reassignTransactionsToDefault) {
      throw Exception('Pilih salah satu opsi penanganan transaksi.');
    }

    if (id == _defaultWalletId) {
      throw Exception('Dompet default tidak dapat dihapus.');
    }

    final transactionService = TransactionService();

    if (reassignTransactionsToDefault) {
      final defaultWalletId = await _ensureDefaultWallet();
      await transactionService.reassignWalletReference(id, defaultWalletId);
    } else if (deleteTransactions) {
      await transactionService.deleteTransactionsByWallet(id);
    }

    await _db.doc(id).delete();
  }

  Future<String> _ensureDefaultWallet() async {
    final defaultDoc = _db.doc(_defaultWalletId);
    final snapshot = await defaultDoc.get();
    if (snapshot.exists) {
      return defaultDoc.id;
    }
    await defaultDoc.set(Wallet(name: 'Dompet Default', balance: 0.0).toJson());
    return defaultDoc.id;
  }

  Future<void> adjustBalance(String walletId, double delta) async {
    if (walletId.isEmpty) return;
    try {
      await _db.doc(walletId).update({'balance': FieldValue.increment(delta)});
    } catch (e) {
      rethrow;
    }
  }

  Future<Wallet?> getById(String id) async {
    if (id.isEmpty) return null;

    try {
      final doc = await _db.doc(id).get();

      if (doc.exists) {
        return Wallet.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
