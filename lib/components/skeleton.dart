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

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget screen,
  ) {
    final isActive = title == label;
    return GestureDetector(
      onTap: () => _navigateTo(context, screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.button.withOpacity(0.15)
                  : Colors.transparent,
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      resizeToAvoidBottomInset: false,
      body: content,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.category, 'Kategori', CategoryScreen()),
            _navItem(context, Icons.wallet, 'Dompet', WalletsScreen()),
            _navItem(context, Icons.money, 'Transaksi', TransactionsScreen()),
            _navItem(context, Icons.settings, 'Setelan', SettingsScreen()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: actionButton,
    );
  }
}
