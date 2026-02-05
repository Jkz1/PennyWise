import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes (Logged in vs Logged out)
  Stream<User?> get userStatus => _auth.authStateChanges();

  // Login Method
  Future<User?> login(String email, String password) async {
    try {
      final res = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return res.user;
    } on FirebaseAuthException catch (e) {
      // Throw the error code so the UI can catch and display it
      throw e.message ?? "An unknown error occurred";
    }
  }
  Future<User?> register(String email, String password) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return res.user;
    } on FirebaseAuthException catch (e) {
      // Throw the error code so the UI can catch and display it
      throw e.message ?? "An unknown error occurred";
    }
  }
  // Sign Out
  Future<void> signOut() async => await _auth.signOut();
}