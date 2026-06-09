import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
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
  return FirebaseAuth.instance.authStateChanges().switchMap((user) {
    if (user == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Wallet.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  });
}

  Future<void> update(Wallet wallet) async {
    await _db.doc(wallet.id).update(wallet.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
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
