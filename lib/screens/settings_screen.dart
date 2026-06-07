import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../components/auth_text_box.dart';
import '../components/skeleton.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final AuthService _authService = AuthService();

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

  void _updateProfile() {
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

    _authService.updateEmail(emailController.text);
    _authService.updatePassword(passwordController.text);

    emailController.text = '';
    passwordController.text = '';
    passwordConfirmController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Setelan',
      content: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.button,
                  foregroundColor: AppTheme.textInverted,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Update Profil",
                  style: TextStyle(
                    color: AppTheme.textInverted,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _authService.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonDanger,
                  foregroundColor: AppTheme.textInverted,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    color: AppTheme.textInverted,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
