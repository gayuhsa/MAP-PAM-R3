import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:rxdart/rxdart.dart';
import '../models/category.dart';

class CategoryService {
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
    if (kDebugMode) {
      debugPrint('WARNING: Memulai pembuatan kategori baru.');
    }
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
    if (kDebugMode) {
      debugPrint('WARNING: Memulai pembaruan kategori ${category.id}.');
    }
    await _db.doc(category.id).update(category.toJson());
  }

  Future<void> delete(String id) async {
    if (kDebugMode) {
      debugPrint('WARNING: Memulai penghapusan kategori $id.');
    }
    await _db.doc(id).delete();
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
