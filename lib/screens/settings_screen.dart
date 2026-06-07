import 'package:flutter/material.dart';
import 'package:myapp/theme.dart';
import '../components/auth_text_box.dart';
import '../components/skeleton.dart';
import '../services/auth_service.dart';

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.button,
                  foregroundColor: AppTheme.textInverted,
                  padding: EdgeInsets.all(24),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonDanger,
                  foregroundColor: AppTheme.textInverted,
                  padding: EdgeInsets.all(24),
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
