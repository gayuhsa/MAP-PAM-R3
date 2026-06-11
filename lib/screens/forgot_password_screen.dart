import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:email_validator/email_validator.dart';
import '../components/auth_text_box.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetEmail() async {
    final email = emailController.text.trim();

    // Validasi input kosong
    if (email.isEmpty) {
      _showErrorDialog("Email tidak boleh kosong.");
      return;
    }

    // Validasi format email
    if (!EmailValidator.validate(email)) {
      _showErrorDialog("Format email tidak valid.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kirim email reset password
      await _authService.sendPasswordResetEmail(email);

      setState(() => _emailSent = true);

      _showSuccessDialog(
        "Email Telah Dikirim",
        "Jika email Anda terdaftar di sistem kami, Anda akan menerima email dengan instruksi untuk mengatur ulang password.",
      );
    } catch (e) {
      _showErrorDialog(_extractErrorMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractErrorMessage(String error) {
    if (error.contains("user-not-found")) {
      return "Email tidak terdaftar di sistem kami.";
    } else if (error.contains("invalid-email")) {
      return "Format email tidak valid.";
    } else if (error.contains("too-many-requests")) {
      return "Terlalu banyak percobaan. Silakan coba beberapa saat lagi.";
    }
    return error;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Gagal"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Kembali ke Login"),
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
                Image.asset('image/nomi2.png', width: 100),

                SizedBox(height: 2),

                Text(
                  "Lupa Password",
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Masukkan email Anda untuk menerima link reset password",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.text, fontSize: 14),
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AuthTextBox(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail,
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
                      : Text("Kirim Email Reset"),
                ),
                SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppTheme.text),
                    children: [
                      TextSpan(text: "Sudah ingat password? "),
                      TextSpan(
                        text: "Kembali ke Login",
                        style: TextStyle(
                          color: AppTheme.button2,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
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

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
