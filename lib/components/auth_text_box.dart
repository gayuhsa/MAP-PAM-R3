import 'package:flutter/material.dart';
import '../theme.dart';

class AuthTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const AuthTextBox({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.all(16),
          fillColor: AppTheme.authTextBox,
          filled: true,
          hintText: hintText,
          isDense: true,
        ),
      ),
    );
  }
}
