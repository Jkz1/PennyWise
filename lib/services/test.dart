import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<Map<String, dynamic>> pendingExpenses = [
  {
    'title': 'Bakso',
    'category': "Food",
    'amount': 5.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'BBM',
    'category': "Transport",
    'amount': 15.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'Rice',
    'category': "Shopping",
    'amount': 30.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'WiFi',
    'category': "Bills",
    'amount': 50.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'Demam',
    'category': "Health",
    'amount': 7.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'Buy Sugar',
    'category': "Shopping",
    'amount': 2.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
  {
    'title': 'TokenListrik',
    'category': "Bills",
    'amount': 70.0,
    'wallet': 'z6KjKAPEXio6L2u1IQvi',
    'isExpense': true,
  },
];
Future<void> recordExpense() async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  final walletRef = _db
      .collection('users')
      .doc(uid)
      .collection('wallets')
      .doc("z6KjKAPEXio6L2u1IQvi");

  try {
    for (var expense in pendingExpenses) {
      final transactionRef = _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();
      await _db.runTransaction((transaction) async {
        // 1. Get the current wallet data
        DocumentSnapshot walletSnapshot = await transaction.get(walletRef);

        if (!walletSnapshot.exists) {
          throw Exception("Wallet does not exist!");
        }

        // 2. Calculate new balance
        double currentBalance = walletSnapshot.get('balance').toDouble();
        double newBalance = currentBalance - expense['amount'];

        // 3. Update Wallet Balance
        transaction.update(walletRef, {'balance': newBalance});

        // 4. Create the Transaction Record
        transaction.set(transactionRef, {
          'title': expense['title'],
          'amount': expense['amount'],
          'isExpense': expense['isExpense'],
          'category': expense['category'],
          'wallet': expense['wallet'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      print("Transaction Successful: ${expense['title']}");
    }
  } catch (e) {
    print("Transaction Failed: $e");
  }
}
