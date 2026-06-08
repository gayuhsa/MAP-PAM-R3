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

  Future<Map<String, dynamic>> _getTransactionDetails() async {
    try {
      final category = await CategoryService().getById(transaction.categoryId);
      final wallet = await WalletService().getById(transaction.walletId);
      
      return {
        'category': category?.name ?? 'Kategori Umum',
        'wallet': wallet?.name ?? 'Dompet Utama',
        'walletPrice': wallet?.balance ?? 0.0,
      };
    } catch (_) {
      return {'category': 'Memuat...', 'wallet': 'Memuat...', 'walletPrice': 0.0};
    }
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
      padding: const EdgeInsets.all(12),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getTransactionDetails(),
        builder: (context, snapshot) {
          final categoryName = snapshot.data?['category'] ?? 'Memuat...';
          final walletName = snapshot.data?['wallet'] ?? 'Memuat...';
          final double walletPrice = (snapshot.data?['walletPrice'] ?? 0.0).toDouble();

          final double totalCalculated = walletPrice * transaction.amount;

          String formattedTotalIdr = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 2,
          ).format(totalCalculated);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Agar kolom menciut mengikuti tinggi konten
            children: [
              Text(
                categoryName,
                style: const TextStyle(color: AppTheme.text, fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                walletName,
                style: TextStyle(color: AppTheme.text.withOpacity(0.7), fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              Text(
                'Jumlah',
                style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${transaction.amount.toInt()}x', 
                style: const TextStyle(color: AppTheme.text, fontSize: 18),
              ),
              const SizedBox(height: 4),

              Text(
                'Jenis',
                style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                transaction.type.isNotEmpty ? transaction.type : '-',
                style: const TextStyle(color: AppTheme.text, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // KUNCI: Jarak dari Jenis ke Total dibuat dekat (hanya 8)
              const SizedBox(height: 8), 

              // Bagian Total dan Tombol digabung sejajar biar nempel pas di bawah Jenis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      CardChip(
                        backgroundColor: chipColor,
                        children: [
                          Icon(chipIcon, size: 14),
                          Text(
                            formattedTotalIdr, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), 
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Tombol aksi pas di sebelah kanan total
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.editButton,
                          foregroundColor: AppTheme.textInverted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => modalCallback(transaction: transaction),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.trashButton,
                          foregroundColor: AppTheme.textInverted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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