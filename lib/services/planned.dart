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

  // READ: Get a stream of maps (includes the document ID)
  // Stream<List<Map<String, dynamic>>> watchPlannedItems(String uid) {
  //   return _getRef(uid).snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       // We merge the document ID into the map so you can update/delete it later
  //       final data = doc.data();
  //       data['id'] = doc.id;
  //       return data;
  //     }).toList();
  //   });
  // }

  // UPDATE: Update specific fields
  Future<void> updatePlannedItem(
    String uid,
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _getRef(uid).doc(itemId).update(updates);
  }

  // DELETE: Remove the document
  Future<void> deletePlannedItem(String uid, String itemId) async {
    await _getRef(uid).doc(itemId).delete();
  }
}
