import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkData() async {
    _firestore.collection('users').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print("User ID: ${doc.id}, Data: ${doc.data()}");
      }
    });
  }
  
}
