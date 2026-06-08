import 'package:flutter/material.dart';
import '../components/b_transaction_card.dart';
import '../components/modal.dart';
import '../components/skeleton.dart';
import '../models/b_transaction.dart';
import '../models/dropdown_options.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final CategoryService _categoryService = CategoryService();
  final TransactionService _transactionService = TransactionService();
  final WalletService _walletService = WalletService();

  void _showTransactionModal({BTransaction? transaction}) async {
    final categories = await _categoryService.getAllByUserId().first;
    final wallets = await _walletService.getAllByUserId().first;
    final isEditing = transaction != null;

    final Map<String, TextEditingController> fields = {
      'Dompet': TextEditingController(
        text: isEditing ? transaction.walletId : '',
      ),
      'Kategori': TextEditingController(
        text: isEditing ? transaction.categoryId : '',
      ),
      'Jumlah': TextEditingController(
        text: isEditing ? '${transaction.amount}' : '',
      ),
      'Jenis': TextEditingController(
        text: isEditing ? transaction.type : '',
      ),
    };

    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
        fields: fields,
        dropdownFields: {
          'Dompet': wallets
              .map((w) => DropdownOptions(id: w.id ?? '', name: w.name))
              .toList(),
          'Kategori': categories
              .map((c) => DropdownOptions(id: c.id ?? '', name: c.name))
              .toList(),
        },
      ),
    );

    if (isConfirmed == true) {
      final String walletId = fields['Dompet']!.text.trim();
      final String categoryId = fields['Kategori']!.text.trim();
      final double balance =
          double.tryParse(fields['Jumlah']!.text.trim()) ?? 0.0;
      final String type = fields['Jenis']!.text.trim().isEmpty 
          ? 'EXPENSE' 
          : fields['Jenis']!.text.trim();

      if (walletId.isEmpty || categoryId.isEmpty) return;

      if (isEditing) {
        transaction.walletId = walletId;
        transaction.categoryId = categoryId;
        transaction.amount = balance;
        transaction.type = type;
        _transactionService.update(transaction);
      } else {
        _transactionService.create(
          BTransaction(
            walletId: walletId,
            categoryId: categoryId,
            amount: balance,
            dateTime: DateTime.now(),
            type: type,
          ),
        );
      }
    }
  }

  Widget _createActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.card,
      foregroundColor: AppTheme.text,
      onPressed: () => _showTransactionModal(),
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Transaksi',
      actionButton: _createActionButton(),
      content: StreamBuilder<List<BTransaction>>(
        stream: _transactionService.getAllByUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          // GridView dengan rasio tinggi yang sudah disesuaikan agar pas
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // Menjadi 2 kolom ke samping
              crossAxisSpacing: 12,       // Jarak horizontal antar kartu
              mainAxisSpacing: 12,        // Jarak vertikal antar kartu
              childAspectRatio: 1.2,      // PERBAIKAN: Diubah ke 0.8 agar kotak memanjang kebawah dan muat semua teks
            ),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              return BTransactionCard(
                transaction: doc,
                modalCallback: _showTransactionModal,
                deleteCallback: _transactionService.delete,
              );
            },
          );
        },
      ),
    );
  }
}