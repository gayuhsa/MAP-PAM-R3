import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    await _db.add(category.toJson());
  }

  Stream<List<Category>> getAllByUserId() {
    try {
      return _db.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Category.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]); 
    }
  }

  Future<void> update(Category category) async {
    await _db.doc(category.id).update(category.toJson());
  }

  Future<void> delete(String id) async {
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
