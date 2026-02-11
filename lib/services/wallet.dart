import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;


  Future<DocumentSnapshot> test() async {
    return await _db
        .collection('users')
        .doc(uid)
        .get();
  }

  Future<void> addWallet(String name, int colorValue) async {
    await _db.collection('users').doc(uid).collection('wallets').add({
      'name': name,
      'balance': 0.0,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> transferBalanceWallets(String fromWalletId, String toWalletId, double amount) async {
    final fromWalletRef =
        _db.collection('users').doc(uid).collection('wallets').doc(fromWalletId);
    final toWalletRef =
        _db.collection('users').doc(uid).collection('wallets').doc(toWalletId);

    await _db.runTransaction((transaction) async {
      final fromSnapshot = await transaction.get(fromWalletRef);
      final toSnapshot = await transaction.get(toWalletRef);

      final dynamic fromBalance =
          (fromSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;
      final dynamic toBalance =
          (toSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      transaction.update(fromWalletRef, {'balance': fromBalance - amount});
      transaction.update(toWalletRef, {'balance': toBalance + amount});
    });
  }

  // DELETE: Remove a wallet
  Future<void> deleteWallet(String walletId) async {
    await _db.collection('users').doc(uid).collection('wallets').doc(walletId).delete();
  }
}