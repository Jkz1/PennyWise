// providers/wallet_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          // 1. Get the data map
          final data = doc.data();
          // 2. Add the ID into the map
          data['id'] = doc.id;

          return data;
        }).toList();
      });
});

final transactionHistory = StreamProvider<List<dynamic>>((ref) {
  
  final walletsAsync = ref.watch(walletListProvider);
  final firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  return firestore
      .collection('users')
      .doc(uid)
      .collection('transactions')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final wallets = walletsAsync.value ?? [];

          final data = doc.data();

          final Timestamp? timestamp = data['timestamp'] as Timestamp?;

          // 2. Convert to DateTime (handle null in case of pending server writes)
          final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();

          final wallet = wallets.firstWhere(
            (w) => w['id'] == data['wallet'],
            orElse: () => {'name': 'Unknown Wallet'},
          );

          // 3. Format it: HH:mm dd/MM/yyyy
          // Note: HH is 24-hour, hh is 12-hour.
          final String formattedDate = DateFormat(
            'HH:mm dd/MM/yyyy',
          ).format(dateTime);
          data['timestamp'] = formattedDate;
          return {
            ...data,
            "walletName" : wallet['name'],
            'color': wallet['colorValue'] ?? 0xFF000000,
          };
        }).toList();
      });
});

final combinedTransactionProvider = StreamProvider<List<dynamic>>((ref) {
  final walletsAsync = ref.watch(walletListProvider);

  final firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  return firestore
      .collection('users')
      .doc(uid)
      .collection('walletsTransactions')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        // Get the actual list of wallets from the AsyncValue
        final wallets = walletsAsync.value ?? [];


        return snapshot.docs.map((doc) {
          final data = doc.data();

          // 2. Find the wallet object for "fromWallet"
          final fromWallet = wallets.firstWhere(
            (w) => w['id'] == data['fromWalletId'],
            orElse: () => {'walletName': 'Unknown Wallet'},
          );

          // 3. Find the wallet object for "toWallet"
          final toWallet = wallets.firstWhere(
            (w) => w['id'] == data['toWalletId'],
            orElse: () => {'walletName': 'Unknown Wallet'},
          );

          // 4. Inject the names into the transaction data
          final Timestamp? timestamp = data['timestamp'] as Timestamp?;

          // 2. Convert to DateTime (handle null in case of pending server writes)
          final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();

          // 3. Format it: HH:mm dd/MM/yyyy
          // Note: HH is 24-hour, hh is 12-hour.
          final String formattedDate = DateFormat(
            'HH:mm dd/MM/yyyy',
          ).format(dateTime);
          data['timestamp'] = formattedDate;
          return {
            ...data,
            'from': fromWallet['name'],
            'to': toWallet['name'],
            'color':
                fromWallet['colorValue'] ??
                0xFF000000, // Default color if not found
          };
        }).toList();
      });
});

final totalBalanceProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletListProvider).value ?? [];
  return wallets.fold(0.0, (sum, item) {
    // Logic to extract double from your data map or model
    final balance = double.tryParse(item['balance'].toString()) ?? 0.0;
    return sum + balance;
  });
});
