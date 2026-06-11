import 'package:firebase_auth/firebase_auth.dart';

/// Konfigurasi Firebase untuk Password Reset
class FirebaseConfig {
  /// Set Action URL untuk password reset
  /// Gunakan sebelum mengirim reset email
  static Future<void> setPasswordResetUrl() async {
    try {
      await FirebaseAuth.instance.setLanguageCode('id');
    } catch (e) {
      print('Error setting Firebase language: $e');
    }
  }

  /// Ambil konfigurasi reset password
  static String getPasswordResetUrl() {
    // Sesuaikan dengan project Anda
    const String projectId = 'yourProjectId'; // Ganti dengan project ID Anda
    const String actionUrl =
        'https://$projectId.firebaseapp.com/__/auth/action';

    return actionUrl;
  }

  /// Helper untuk ekstrak OOB Code dari URL (untuk web apps)
  static String? extractOobCodeFromUrl(Uri url) {
    return url.queryParameters['oobCode'];
  }

  /// Helper untuk ekstrak mode dari URL
  static String? extractModeFromUrl(Uri url) {
    return url.queryParameters['mode'];
  }
}
