import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:penny_wise/model/expenseCategory.dart';

class PlannedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Helper to get the specific user's planned collection path
  CollectionReference<Map<String, dynamic>> _getRef(String uid) {
    return _db.collection('users').doc(uid).collection('planned');
  }

  // CREATE: Add a new item with default values
  Future<void> addPlannedItem({
    required String title,
    required String category,
    required double amount,
    required DateTime dueDate,
    bool isMonthly = false,
  }) async {
    await _getRef(uid).add({
      'title': title,
      'category': category,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate), // Firestore needs Timestamps
      'isMonthly': isMonthly,
      'isPay': false, // Default as requested
    });
  }

  Future<void> logPlanned({
    required String plannedId,
    required String walletId,
  }) async {
    final plannedRef = _getRef(uid).doc(plannedId);
    final walletRef = _db
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .doc(walletId);
    final transactionRef = _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc();

    await _db.runTransaction((transaction) async {
      // 1. Get the Planned item data
      final plannedDoc = await transaction.get(plannedRef);
      if (!plannedDoc.exists) {
        throw Exception('Planned item not found');
      }

      // 2. Get the Wallet data to check/update balance
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Wallet not found');
      }

      final data = plannedDoc.data()!;
      final amount = (data['amount'] as num).toDouble(); // Use num for safety
      final currentBalance =
          (walletDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      // 3. Update the Wallet Balance
      transaction.update(walletRef, {'balance': currentBalance - amount});

      // 4. Create the Transaction Log
      transaction.set(transactionRef, {
        'title': data['title'],
        'category': data['category'],
        'amount': amount,
        'timestamp': Timestamp.now(),
        'wallet': walletId,
        'isPlanned': true,
        'isExpense': true,
      });

      // 5. Update Planned Item (Recurring vs One-time)
      final dueDate = (data['dueDate'] as Timestamp).toDate();
      if (data['isMonthly'] == true) {
        transaction.update(plannedRef, {
          'dueDate': Timestamp.fromDate(
            DateTime(dueDate.year, dueDate.month + 1, dueDate.day),
          ),
        });
      } else {
        transaction.update(plannedRef, {'isPay': true});
      }
    });
  }

  // UPDATE: Update specific fields
  Future<void> updatePlannedItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _getRef(uid).doc(itemId).update(updates);
  }

  // DELETE: Remove the document
  Future<void> deletePlannedItem(String itemId) async {
    await _getRef(uid).doc(itemId).delete();
  }
}
