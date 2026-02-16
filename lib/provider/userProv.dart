import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.data();
      });
});