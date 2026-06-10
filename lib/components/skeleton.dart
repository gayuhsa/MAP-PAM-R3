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
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Kategori'
                          ? Color.fromARGB(255, 178, 234, 176)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.category,
                      color: title == 'Kategori'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Kategori'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: title == 'Kategori'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, WalletsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Dompet'
                          ? Color.fromARGB(255, 178, 234, 176)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.wallet,
                      color: title == 'Dompet'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dompet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Dompet'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: title == 'Dompet'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, TransactionsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Transaksi'
                          ? Color.fromARGB(255, 178, 234, 176)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.money,
                      color: title == 'Transaksi'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Transaksi'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: title == 'Transaksi'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, SettingsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Setelan'
                          ? Color.fromARGB(255, 178, 234, 176)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: title == 'Setelan'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Setelan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Setelan'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: title == 'Setelan'
                          ? AppTheme.text
                          : Colors.grey[600],
                    ),
                  ),
                ],
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
