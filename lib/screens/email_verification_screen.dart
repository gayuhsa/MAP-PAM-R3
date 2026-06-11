import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../theme.dart';
import 'category_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  /// Auto check apakah email sudah terverifikasi
  void _startEmailVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(Duration(seconds: 3), (
      timer,
    ) async {
      try {
        await _authService.refreshUser();

        if (_authService.isEmailVerified()) {
          _verificationCheckTimer?.cancel();
          _countdownTimer?.cancel();

          _showSuccessDialog(
            "Email Terverifikasi!",
            "Selamat, email Anda sudah terverifikasi. Silakan masuk ke aplikasi.",
            () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
                (route) => false,
              );
            },
          );
        }
      } catch (e) {
        print('Error checking verification: $e');
      }
    });
  }

  /// Kirim ulang email verifikasi
  Future<void> _resendVerificationEmail() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resendEmailVerification();

      _showInfoDialog(
        "Email Terkirim",
        "Email verifikasi telah dikirim ulang ke ${widget.email}. Silakan cek inbox Anda.",
      );

      _startResendCountdown();
    } catch (e) {
      _showErrorDialog(
        "Gagal Mengirim Email",
        _extractErrorMessage(e.toString()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Countdown untuk disable tombol resend
  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _resendCountdown--);
      }

      if (_resendCountdown == 0) {
        timer.cancel();
      }
    });
  }

  String _extractErrorMessage(String error) {
    if (error.contains("too-many-requests")) {
      return "Terlalu banyak permintaan. Silakan coba beberapa saat lagi.";
    }
    return error;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message, VoidCallback onClose) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: AppTheme.background,
            ),
            margin: EdgeInsets.symmetric(horizontal: 32),
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon verifikasi
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.editButton.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: AppTheme.editButton,
                  ),
                ),

                SizedBox(height: 20),

                /// Judul
                Text(
                  "Verifikasi Email",
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                /// Deskripsi
                Text(
                  "Email verifikasi telah dikirim ke:",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.text, fontSize: 14),
                ),

                SizedBox(height: 8),

                /// Email
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.authContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.email,
                    style: TextStyle(
                      color: AppTheme.button2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                /// Instruksi
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.authContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Langkah-langkah:",
                        style: TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildStep("1", "Buka email di inbox Anda"),
                      SizedBox(height: 8),
                      _buildStep(
                        "2",
                        "Klik link verifikasi yang kami kirimkan",
                      ),
                      SizedBox(height: 8),
                      _buildStep(
                        "3",
                        "Kembali ke aplikasi dan akses akan aktif otomatis",
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                /// Loading indicator
                if (_authService.isEmailVerified() == false)
                  Column(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.editButton,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Menunggu verifikasi email...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.text, fontSize: 12),
                      ),
                    ],
                  ),

                SizedBox(height: 24),

                /// Resend button
                ElevatedButton(
                  onPressed: _isLoading || _resendCountdown > 0
                      ? null
                      : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.editButton,
                    foregroundColor: AppTheme.textInverted,
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.textInverted,
                            ),
                          ),
                        )
                      : Text(
                          _resendCountdown > 0
                              ? "Kirim Ulang ($_resendCountdown)"
                              : "Kirim Ulang Email",
                        ),
                ),

                SizedBox(height: 16),

                /// Ganti email / kembali
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppTheme.text),
                    children: [
                      TextSpan(text: "Email salah? "),
                      TextSpan(
                        text: "Kembali ke Login",
                        style: TextStyle(
                          color: AppTheme.button2,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _verificationCheckTimer?.cancel();
                            _countdownTimer?.cancel();
                            _authService.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.editButton,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppTheme.textInverted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.text, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
