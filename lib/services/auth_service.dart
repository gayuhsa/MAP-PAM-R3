import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUserId => _auth.currentUser?.uid;

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String currentEmail = user.email?.trim().toLowerCase() ?? '';
        String sanitizedNewEmail = newEmail.trim().toLowerCase();
        if (currentEmail == sanitizedNewEmail) return;

        await user.verifyBeforeUpdateEmail(newEmail);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
