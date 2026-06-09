import 'package:flutter/material.dart';
import '../screens/budget_realization_screen.dart'; // ← BARU
import '../screens/category_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shopping_record_screen.dart'; // ← BARU
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => target));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.bottomBar,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(color: AppTheme.background, child: content),
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.bottomBar,
<<<<<<< HEAD
        child: SingleChildScrollView(
          // ← BARU: biar 6 menu muat di layar kecil
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.category,
                label: 'Kategori',
                onTap: () => _navigateTo(context, const CategoryScreen()),
              ),
              _NavItem(
                icon: Icons.wallet,
                label: 'Dompet',
                onTap: () => _navigateTo(context, const WalletsScreen()),
              ),
              _NavItem(
                icon: Icons.money,
                label: 'Transaksi',
                onTap: () => _navigateTo(context, const TransactionsScreen()),
              ),
              _NavItem(
                // ← BARU
                icon: Icons.shopping_cart,
                label: 'Belanja',
                onTap: () => _navigateTo(context, const ShoppingRecordScreen()),
=======
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                _navigateTo(context, const CategoryScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ditambahkan lingkaran penanda aktif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Kategori' ? const Color.fromARGB(255, 178, 234, 176) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.category,
                      color: title == 'Kategori' ? AppTheme.text : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Kategori' ? FontWeight.bold : FontWeight.normal,
                      color: title == 'Kategori' ? AppTheme.text : Colors.grey[600],
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, const WalletsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ditambahkan lingkaran penanda aktif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Dompet' ? const Color.fromARGB(255, 178, 234, 176) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.wallet,
                      color: title == 'Dompet' ? AppTheme.text : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dompet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Dompet' ? FontWeight.bold : FontWeight.normal,
                      color: title == 'Dompet' ? AppTheme.text : Colors.grey[600],
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, const TransactionsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ditambahkan lingkaran penanda aktif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Transaksi' ? const Color.fromARGB(255, 178, 234, 176) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.money,
                      color: title == 'Transaksi' ? AppTheme.text : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Transaksi' ? FontWeight.bold : FontWeight.normal,
                      color: title == 'Transaksi' ? AppTheme.text : Colors.grey[600],
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateTo(context, const SettingsScreen());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ditambahkan lingkaran penanda aktif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: title == 'Setelan' ? const Color.fromARGB(255, 178, 234, 176) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: title == 'Setelan' ? AppTheme.text : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Setelan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: title == 'Setelan' ? FontWeight.bold : FontWeight.normal,
                      color: title == 'Setelan' ? AppTheme.text : Colors.grey[600],
                    ),
                  )
                ],
>>>>>>> ea2be0a698f92d254424119c728ea7a36748b73b
              ),
              _NavItem(
                // ← BARU
                icon: Icons.bar_chart,
                label: 'Realisasi',
                onTap: () =>
                    _navigateTo(context, const BudgetRealizationScreen()),
              ),
              _NavItem(
                icon: Icons.settings,
                label: 'Setelan',
                onTap: () => _navigateTo(context, const SettingsScreen()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: actionButton,
    );
  }
<<<<<<< HEAD
}

// ← BARU: widget helper agar kode navbar lebih rapi
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
=======
}
>>>>>>> ea2be0a698f92d254424119c728ea7a36748b73b
