import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart' show kDebugMode;
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

  Future<DocumentReference> create(BTransaction transaction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (kDebugMode) {
      print("Firestore Creating Transaction for User: ${user?.uid}");
    }
    final docRef = await _db.add(transaction.toJson());
    if (kDebugMode) {
      print(
        "Firestore Created Transaction Document: ${docRef.id} at path: ${docRef.path}",
      );
    }
    return docRef;
  }

  Stream<List<BTransaction>> getAllByUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error("User belum login!");
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
      return Stream.error("User belum login!");
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
    await _db.doc(transaction.id).update(transaction.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
