import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet.dart';

class WalletService {
  final CollectionReference _db = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('wallets');

  Future<void> create(Wallet wallet) async {
    await _db.add(wallet.toJson());
  }

  Stream<List<Wallet>> getAllByUserId() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Wallet.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> update(Wallet wallet) async {
    await _db.doc(wallet.id).update(wallet.toJson());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  Future<Wallet?> getById(String id) async {
  if (id.isEmpty) return null;
  try {
    final doc = await _db.doc(id).get();
    if (doc.exists) {
      // PERHATIKAN: Ganti 'Wallet' dengan nama class model Dompet kamu yang sebenarnya jika berbeda
      return Wallet.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  } catch (e) {
    print('Error ambil data dompet: $e');
    return null;
  }
}}
