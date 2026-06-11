import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _auth.setLanguageCode('id');
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

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

  String getCurrentUserEmail() {
    return _auth.currentUser?.email ?? '';
  }

  bool validateEmailFormat(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Cek apakah email sudah terverifikasi
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Refresh user data untuk update status verifikasi email
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Kirim ulang email verifikasi
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
