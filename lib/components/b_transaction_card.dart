import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/b_transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../services/category_service.dart';
import '../services/wallet_service.dart';
import '../theme.dart';
import 'card_chip.dart';

class BTransactionCard extends StatefulWidget {
  final BTransaction transaction;
  final void Function({BTransaction? transaction}) modalCallback;
  final Future<void> Function(String) deleteCallback;

  const BTransactionCard({
    super.key,
    required this.transaction,
    required this.modalCallback,
    required this.deleteCallback,
  });

  @override
  State<BTransactionCard> createState() => _BTransactionCardState();
}

class _BTransactionCardState extends State<BTransactionCard> {
  late Stream<Map<String, dynamic>> _detailsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _detailsStream = _getTransactionDetailsStream();
  }

  @override
  void didUpdateWidget(covariant BTransactionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transaction.walletId != widget.transaction.walletId ||
        oldWidget.transaction.categoryId != widget.transaction.categoryId) {
      setState(() {
        _initStream();
      });
    }
  }

  Stream<Map<String, dynamic>> _getTransactionDetailsStream() {
    final categoryService = CategoryService();
    final walletService = WalletService();

    return walletService.getAllByUserId().asyncMap((wallets) async {
      List<Category> categories = [];
      try {
        categories = await categoryService.getAllByUserId().first;
      } catch (_) {}

      final wallet = wallets.firstWhere(
        (w) => w.id == widget.transaction.walletId,
        orElse: () => Wallet(id: '', name: 'Dompet Utama', balance: 0),
      );

      final category = categories.firstWhere(
        (c) => c.id == widget.transaction.categoryId,
        orElse: () => Category(id: '', name: 'Kategori Umum'),
      );

<<<<<<< HEAD
      return {
        'category': category.name ?? 'Kategori Umum',
        'wallet': wallet.name ?? 'Dompet Utama',
        'walletPrice': wallet.balance ?? 0.0,
      };
=======
      return {'category': category.name, 'wallet': wallet.name};
>>>>>>> d46f523152a3ceafb7b6443d3fb4f4ca9db46e08
    });
  }

  String _formatDate(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return '${dateTime.day.toString().padLeft(2, '0')} '
          '${_monthNames[dateTime.month - 1]} ${dateTime.year}';
    }
  }

  String _formatAmount(double amount) {
    try {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(amount);
    } catch (_) {
      return 'Rp${amount.toStringAsFixed(0)}';
    }
  }

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isIncome = widget.transaction.type.toUpperCase() == 'INCOME';
    final Color typeColor = isIncome
        ? AppTheme.chipIncome
        : AppTheme.chipExpense;
    final Color typeBg = isIncome
        ? AppTheme.chipIncome.withOpacity(0.12)
        : AppTheme.chipExpense.withOpacity(0.12);
    final IconData typeIcon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final String typeLabel = isIncome ? 'Pemasukan' : 'Pengeluaran';

    final String formattedDate = _formatDate(widget.transaction.dateTime);
    final String formattedAmount = _formatAmount(widget.transaction.amount);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(14),
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _detailsStream,
        builder: (context, snapshot) {
          final categoryName = snapshot.data?['category'] ?? 'Memuat...';
          final walletName = snapshot.data?['wallet'] ?? 'Memuat...';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                formattedAmount,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),
              Divider(color: AppTheme.cardBorder, height: 1),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.category_rounded,
                      label: 'Kategori',
                      value: categoryName,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Dompet',
                      value: walletName,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded, size: 18),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.editButton,
                      foregroundColor: AppTheme.textInverted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        widget.modalCallback(transaction: widget.transaction),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_rounded, size: 18),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.trashButton,
                      foregroundColor: AppTheme.textInverted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        widget.deleteCallback(widget.transaction.id ?? ''),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
