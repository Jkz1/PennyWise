import 'package:firebase_auth/firebase_auth.dart';

var auth = FirebaseAuth.instance;
Future<void> register(String email, String password) async {
  try {
    final res = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    print("Register success: ${res.user?.uid}");
  } on FirebaseAuthException catch (e) {
    print("Firebase error: ${e.code}");

    print(e.message);
  } catch (e) {
    print("Unexpected error: $e");
  }
}
