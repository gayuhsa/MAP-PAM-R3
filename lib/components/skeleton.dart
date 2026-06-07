import 'package:flutter/material.dart';
import '../screens/category_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/wallets_screen.dart';
import '../theme.dart';

class Skeleton extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? actionButton;

  const Skeleton({
    super.key,
    required this.title,
    required this.content,
    this.actionButton,
  });

  void _navigateTo(BuildContext context, Widget target) {
    if (ModalRoute.of(context)?.settings.name ==
        target.runtimeType.toString()) {
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => target));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.bottomBar,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(color: AppTheme.background, child: content),
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.bottomBar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                _navigateTo(context, CategoryScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.category), Text('Kategori')],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, WalletsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.wallet), Text('Dompet')],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, TransactionsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.money), Text('Transaksi')],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, SettingsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.settings), Text('Setelan')],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: actionButton,
    );
  }
}
