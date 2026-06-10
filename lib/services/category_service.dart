import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/category.dart';
import 'transaction_service.dart';

class CategoryService {
  static const String _defaultCategoryId = '_default_category';

  CollectionReference get _db {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User belum login!");
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');
  }

  Future<void> create(Category category) async {
    await _db.add(category.toJson());
  }

  Stream<List<Category>> getAllByUserId() {
    return FirebaseAuth.instance.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Category.fromJson(doc.data(), doc.id))
                .toList(),
          );
    });
  }

  Future<void> update(Category category) async {
    await _db.doc(category.id).update(category.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  Future<void> deleteWithTransactionHandling(
    String id, {
    bool deleteTransactions = false,
    bool reassignTransactionsToDefault = false,
  }) async {
    if (deleteTransactions && reassignTransactionsToDefault) {
      throw Exception('Pilih salah satu opsi penanganan transaksi.');
    }

    if (id == _defaultCategoryId) {
      throw Exception('Kategori default tidak dapat dihapus.');
    }

    final transactionService = TransactionService();

    if (reassignTransactionsToDefault) {
      final defaultCategoryId = await _ensureDefaultCategory();
      await transactionService.reassignCategoryReference(id, defaultCategoryId);
    } else if (deleteTransactions) {
      await transactionService.deleteTransactionsByCategory(id);
    }

    await _db.doc(id).delete();
  }

  Future<String> _ensureDefaultCategory() async {
    final defaultDoc = _db.doc(_defaultCategoryId);
    final snapshot = await defaultDoc.get();
    if (snapshot.exists) {
      return defaultDoc.id;
    }
    await defaultDoc.set(Category(name: 'Default').toJson());
    return defaultDoc.id;
  }

  Future<Category?> getById(String id) async {
    if (id.isEmpty) return null;

    try {
      final doc = await _db.doc(id).get();

      if (doc.exists) {
        return Category.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
