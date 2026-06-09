import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/b_transaction.dart';
import '../services/category_service.dart';
import '../services/wallet_service.dart';
import '../theme.dart';
import 'card_chip.dart';

class BTransactionCard extends StatelessWidget {
  final BTransaction transaction;
  final void Function({BTransaction? transaction}) modalCallback;
  final void Function(String) deleteCallback;

  const BTransactionCard({
    super.key,
    required this.transaction,
    required this.modalCallback,
    required this.deleteCallback,
  });

  Stream<Map<String, dynamic>> _getTransactionDetailsStream() {
    final categoryService = CategoryService();
    final walletService = WalletService();

    return walletService.getAllByUserId().asyncMap((wallets) async {
      final categories = await categoryService.getAllByUserId().first;

      final wallet = wallets.firstWhere(
        (w) => w.id == transaction.walletId,
        orElse: () => wallets.isNotEmpty ? wallets.first : null as dynamic,
      );

      final category = categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => categories.isNotEmpty ? categories.first : null as dynamic,
      );

      return {
        'category': category.name ?? 'Kategori Umum',
        'wallet': wallet.name ?? 'Dompet Utama',
        'walletPrice': wallet.balance ?? 0.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    Color chipColor = AppTheme.chipExpense;
    IconData chipIcon = Icons.trending_down;

    if (transaction.type.toUpperCase() == 'INCOME') {
      chipColor = AppTheme.chipIncome;
      chipIcon = Icons.trending_up;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _getTransactionDetailsStream(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Memuat data...'),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Data akun tidak sinkron'),
            );
          }
        
          final categoryName = snapshot.data?['category'] ?? 'Memuat...';
          final walletName = snapshot.data?['wallet'] ?? 'Memuat...';
          final double walletPrice = (snapshot.data?['walletPrice'] ?? 0.0)
              .toDouble();

          final double totalCalculated = walletPrice * transaction.amount;

          String formattedTotalIdr = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 2,
          ).format(totalCalculated);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    walletName,
                    style: TextStyle(color: AppTheme.text, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jumlah',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Text(
                    '${transaction.amount.toInt()}x',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jenis',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Text(
                    transaction.type.isNotEmpty ? transaction.type : '-',
                    style: TextStyle(color: AppTheme.text, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formattedTotalIdr,
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CardChip(
                        backgroundColor: chipColor,
                        children: [
                          Icon(chipIcon, size: 14),
                          Text(
                            formattedTotalIdr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.all(8),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.editButton,
                          foregroundColor: AppTheme.textInverted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            modalCallback(transaction: transaction),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete),
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.all(8),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.trashButton,
                          foregroundColor: AppTheme.textInverted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => deleteCallback(transaction.id ?? ''),
                      ),
                    ],
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
