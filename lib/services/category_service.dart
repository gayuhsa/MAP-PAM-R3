import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final CollectionReference _db = FirebaseFirestore.instance.collection(
    'categories',
  );

  Future<void> createCategory(Category category) async {
    await _db.add(category.toJson());
  }

  Stream<List<Category>> getCategories() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateCategory(Category category) async {
    await _db.doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _db.doc(id).delete();
  }
}
