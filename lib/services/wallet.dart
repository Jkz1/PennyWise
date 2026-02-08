import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getWallets() {
    final res = _db
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return res;
  }

  Future<void> addWallet(String name, int colorValue) async {
    await _db.collection('users').doc(uid).collection('wallets').add({
      'name': name,
      'balance': 0.0,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE: Remove a wallet
  Future<void> deleteWallet(String walletId) async {
    await _db.collection('users').doc(uid).collection('wallets').doc(walletId).delete();
  }
}