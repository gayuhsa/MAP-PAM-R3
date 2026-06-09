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

      return {'category': category.name, 'wallet': wallet.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = widget.transaction.type.toUpperCase() == 'INCOME';
    final Color typeColor = isIncome
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    final Color typeBg = isIncome
        ? const Color(0xFF22C55E).withOpacity(0.12)
        : const Color(0xFFEF4444).withOpacity(0.12);
    final IconData typeIcon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final String typeLabel = isIncome ? 'Pemasukan' : 'Pengeluaran';

    final String formattedDate = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(widget.transaction.dateTime);
    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(widget.transaction.amount);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _detailsStream,
        builder: (context, snapshot) {
          final categoryName = snapshot.data?['category'] ?? 'Memuat...';
          final walletName = snapshot.data?['wallet'] ?? 'Memuat...';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Jenis + Tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge Jenis
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        const SizedBox(width: 4),
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
                  // Tanggal
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Jumlah uang (besar)
              Text(
                formattedAmount,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Divider(color: AppTheme.cardBorder, height: 1),
              const SizedBox(height: 10),

              // Info: Kategori & Dompet
              Row(
                children: [
                  // Kategori
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.category_rounded,
                      label: 'Kategori',
                      value: categoryName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dompet
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Dompet',
                      value: walletName,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tombol Edit & Hapus
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
        const SizedBox(width: 6),
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
