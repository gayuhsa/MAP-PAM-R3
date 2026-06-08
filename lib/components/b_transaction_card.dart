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

  // Mengambil detail Kategori dan Dompet (termasuk nominal saldo/harga dompet)
  Future<Map<String, dynamic>> _getTransactionDetails() async {
    try {
      final category = await CategoryService().getById(transaction.categoryId);
      final wallet = await WalletService().getById(transaction.walletId);
      
      return {
        'category': category?.name ?? 'Kategori Umum',
        'wallet': wallet?.name ?? 'Dompet Utama',
        'walletPrice': wallet?.balance ?? 0.0, // Menggunakan .balance sesuai model Wallet kamu
      };
    } catch (_) {
      return {'category': 'Memuat...', 'wallet': 'Memuat...', 'walletPrice': 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan warna label (Chip) berdasarkan tipe transaksi
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

          // Rumus: Harga Satuan Dompet x Jumlah Kuantitas dari Transaksi
          final double totalCalculated = walletPrice * transaction.amount;

          // Format hasil perkalian ke format mata uang Rupiah (Rp)
          String formattedTotalIdr = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 2,
          ).format(totalCalculated);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Bagian Informasi Atas ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Kategori (Judul Utama)
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // 2. Nama Dompet
                  Text(
                    walletName,
                    style: TextStyle(
                      color: AppTheme.text.withOpacity(0.7),
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 3. Jumlah Nominal / Kuantitas (Ditambah huruf 'x' di belakang)
                  Text(
                    'Jumlah',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Text(
                    '${transaction.amount.toInt()}x', 
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 4. Keterangan / Deskripsi Transaksi (Diambil dari field Jenis)
                  Text(
                    'Jenis',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Text(
                    transaction.type.isNotEmpty ? transaction.type : '-',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // --- Bagian Informasi Bawah ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 5. Label Total Utama (Hasil perhitungan perkalian)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          Text(
                            formattedTotalIdr,
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // 6. Label Chip Berwarna (Isinya sama dengan total utama)
                      CardChip(
                        backgroundColor: chipColor,
                        children: [
                          Icon(chipIcon, size: 12),
                          Text(
                            formattedTotalIdr, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 7. Tombol Aksi Edit & Hapus
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.editButton,
                          foregroundColor: AppTheme.textInverted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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