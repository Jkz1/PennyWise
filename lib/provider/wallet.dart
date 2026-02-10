// providers/wallet_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletListProvider = StreamProvider<List<dynamic>>((ref) {
  final firestore = FirebaseFirestore.instance;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // This listener stays active and shares data across the whole app
  return firestore
      .collection('users')
      .doc(uid)
      .collection('wallets')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});


final totalBalanceProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletListProvider).value ?? [];
  return wallets.fold(0.0, (sum, item) {
    // Logic to extract double from your data map or model
    final balance = double.tryParse(item['balance'].toString()) ?? 0.0;
    return sum + balance;
  });
});
