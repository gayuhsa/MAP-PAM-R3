import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/category_screen.dart';
import 'screens/signup_screen.dart';
import 'firebase_options.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP-PAM-R3',
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.background,

        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0D5C52),
          foregroundColor: AppTheme.textInverted,
          elevation: 0,
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppTheme.bottomBar,
          selectedItemColor: AppTheme.button,
          unselectedItemColor: Color(0xFF9E9E9E),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          elevation: 8,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppTheme.button,
          foregroundColor: AppTheme.textInverted,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.button,
            foregroundColor: AppTheme.textInverted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.button),
        useMaterial3: true,
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            return CategoryScreen();
          }

          return SignupScreen();
        },
      ),
    );
  }
}
