import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet.dart';

class WalletService {
  final CollectionReference _db = FirebaseFirestore.instance.collection(
    'wallets',
  );

  Future<void> createWallet(Wallet wallet) async {
    await _db.add(wallet.toJson());
  }

  Stream<List<Wallet>> getWallets() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Wallet.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _db.doc(wallet.id).update(wallet.toJson());
  }

  Future<void> deleteWallet(String id) async {
    await _db.doc(id).delete();
  }
}
