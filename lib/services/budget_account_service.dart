import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_account.dart';

class BudgetAccountService {
  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User belum login!");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budget_accounts');
  }

  Future<void> create(BudgetAccount account) async {
    await _db.add(account.toJson());
  }

  Stream<List<BudgetAccount>> getAll() {
    try {
      return _db.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return BudgetAccount.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<BudgetAccount?> getById(String id) async {
    if (id.isEmpty) return null;
    try {
      final doc = await _db.doc(id).get();
      if (doc.exists) {
        return BudgetAccount.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> update(BudgetAccount account) async {
    await _db.doc(account.id).update(account.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
