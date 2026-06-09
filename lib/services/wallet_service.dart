import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/wallet.dart';

class WalletService {
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
    await _db.add(wallet.toJson());
  }

  Stream<List<Wallet>> getAllByUserId() {
    try {
      return _db.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Wallet.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> update(Wallet wallet) async {
    await _db.doc(wallet.id).update(wallet.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  /// Menyesuaikan saldo wallet secara atomik.
  /// positif = tambah saldo (INCOME), negatif = kurangi saldo (EXPENSE).
  Future<void> adjustBalance(String walletId, double delta) async {
    if (walletId.isEmpty) return;
    try {
      debugPrint(
        'WalletService.adjustBalance: walletId=$walletId delta=$delta',
      );
      await _db.doc(walletId).update({'balance': FieldValue.increment(delta)});
      debugPrint('WalletService.adjustBalance: success for walletId=$walletId');
    } catch (e, st) {
      debugPrint('WalletService.adjustBalance failed: $e');
      debugPrint(st.toString());
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
