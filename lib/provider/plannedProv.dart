import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/wallet.dart';

final plannedItem = StreamProvider<List<dynamic>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  return firestore
      .collection('users')
      .doc(uid)
      .collection('planned')
      .orderBy('dueDate', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final id = doc.id;
          final data = doc.data();
          final cat = data['category'];
          final icon = categories_expenses
              .firstWhere(
                (c) => c.name == cat,
                orElse: () => categories_expenses[6],
              )
              .icon;

          final Timestamp? timestamp = data['dueDate'] as Timestamp?;

          // 2. Convert to DateTime (handle null in case of pending server writes)
          final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();
          final String formattedDate = DateFormat(
            'dd/MM/yyyy',
          ).format(dateTime);
          data['dueDate'] = formattedDate;
          return {...data, 'id': id, 'icon': icon};
        }).toList();
      });
});

final plannedHistoryProvider = Provider<List<dynamic>>((ref) {
  final transactionHistoryAsync = ref.watch(transactionHistory);

  return transactionHistoryAsync.when(
    data: (transactions) {
      final filtered = transactions.where((item) {
        return item is Map && item['isPlanned'] == true;
      }).toList();

      return filtered;
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
