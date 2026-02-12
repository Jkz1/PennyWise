import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addTransaction(
    String walletId,
    bool isExpense,
    double amount,
    String title,
    String category,
  ) async {
    final walletRef = _db
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .doc(walletId);
    final historyRef = _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc();

    await _db.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(walletRef);

      final dynamic walletBalance =
          (walletSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      if (isExpense) {
        transaction.update(walletRef, {'balance': walletBalance - amount});
      } else {
        transaction.update(walletRef, {'balance': walletBalance + amount});
      }

      transaction.set(historyRef, {
        'wallet': walletId,
        'isExpense': isExpense,
        'title': title,
        'category': category,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
