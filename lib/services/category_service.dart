import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';

class CategoryService {
  final CollectionReference _db = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('categories');

  Future<void> create(Category category) async {
    await _db.add(category.toJson());
  }

  Stream<List<Category>> getAllByUserId() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
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
        // Menggunakan model 'Category' sesuai project kamu
        return Category.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error ambil kategori: $e');
      return null;
    }
  }
}