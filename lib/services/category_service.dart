import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';

class CategoryService {
  final CollectionReference _db = FirebaseFirestore.instance.collection(
    'categories',
  );

  Future<void> create(Category category) async {
    category.userId = FirebaseAuth.instance.currentUser!.uid;
    await _db.add(category.toJson());
  }

  Stream<List<Category>> getAllByUserId() {
    return _db
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Category.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  Stream<QuerySnapshot<Object?>> getSnapshots() {
    return _db.snapshots();
  }

  Future<void> update(Category category) async {
    await _db.doc(category.id).update(category.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }
}
