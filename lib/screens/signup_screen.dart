import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:email_validator/email_validator.dart';
import '../components/auth_text_box.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'category_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _signup() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty) {
      _showErrorDialog("Seluruh formulir tidak boleh kosong.");
      return;
    }

    if (!EmailValidator.validate(emailController.text)) {
      _showErrorDialog("Email tidak valid.");
      return;
    }

    if (passwordController.text.length < 6) {
      _showErrorDialog("Password minimal 6 karakter.");
      return;
    }

    if (passwordController.text != passwordConfirmController.text) {
      _showErrorDialog("Password tidak cocok.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Gagal Daftar"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: AppTheme.authContainer,
          ),
          margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Daftar",
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Email",
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              AuthTextBox(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              SizedBox(height: 16),
              Text(
                "Password",
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              AuthTextBox(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 16),
              Text(
                "Konfirmasi Password",
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              AuthTextBox(
                controller: passwordConfirmController,
                hintText: "Konfirmasi Password",
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.button,
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
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        "Daftar",
                        style: TextStyle(
                          color: AppTheme.textInverted,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 16),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppTheme.text, fontSize: 16),
                    children: [
                      TextSpan(text: "Sudah memiliki akun? "),
                      TextSpan(
                        text: "Masuk.",
                        style: TextStyle(
                          color: AppTheme.button,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
