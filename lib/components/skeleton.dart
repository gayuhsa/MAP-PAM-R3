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

  Widget _navItem(BuildContext context, IconData icon, String label, Widget screen) {
    final isActive = title == label;
    return GestureDetector(
      onTap: () => _navigateTo(context, screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.button.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.button : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.button : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: AppTheme.bottomBar,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
=======
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
>>>>>>> 97872e2 (ubah tema jd teal)
      ),
      resizeToAvoidBottomInset: false,
      body: content,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
<<<<<<< HEAD
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
=======
            _navItem(context, Icons.category, 'Kategori', const CategoryScreen()),
            _navItem(context, Icons.wallet, 'Dompet', const WalletsScreen()),
            _navItem(context, Icons.money, 'Transaksi', const TransactionsScreen()),
            _navItem(context, Icons.settings, 'Setelan', const SettingsScreen()),
>>>>>>> 97872e2 (ubah tema jd teal)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: actionButton,
    );
  }
}
