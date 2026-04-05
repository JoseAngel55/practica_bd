import 'package:firebase_auth/firebase_auth.dart';

class EmailAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(String email, String password) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credentials.user?.sendEmailVerification();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> Login(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user?.emailVerified ?? false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> logout() async {
    await _auth.signOut();
  }
}
