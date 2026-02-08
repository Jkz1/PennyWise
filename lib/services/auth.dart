import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    try {
      final res = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return res.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred";
    }
  }

  Future<User?> register(String email, String password, String username) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // 1. Prepare the data map
        final userData = {
          'displayName': username,
          'email': email.trim(),
          'currency': 'USD',
          'uid': user.uid,
        };

        // 2. Save to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallets')
            .add({
              'name': 'Main Wallet',
              'balance': 0,
              'colorValue':
                  Colors.blueAccent.value, // Store color as an integer
              'createdAt': FieldValue.serverTimestamp(),
            });
        // 3. Save to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        String jsonUser = json.encode(userData);
        await prefs.setString('user_data', jsonUser);
        await prefs.setBool('is_logged_in', true);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
