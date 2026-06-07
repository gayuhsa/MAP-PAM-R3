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
        text: isEditing ? '${transaction.categoryId}' : '',
      ),
      'Jumlah': TextEditingController(
        text: isEditing ? '${transaction.amount}' : '',
      ),
      'Jenis': TextEditingController(
        text: isEditing ? '${transaction.type}' : '',
      ),
    };

    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
        fields: fields,
        dropdownFields: {
          'Dompet': categories
              .map((c) => DropdownOptions(id: c.id ?? '', name: c.name))
              .toList(),
          'Kategori': wallets
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
      if (walletId.isEmpty || categoryId.isEmpty) return;

      if (isEditing) {
        transaction.walletId = walletId;
        _transactionService.update(transaction);
      } else {
        _transactionService.create(
          BTransaction(
            walletId: walletId,
            categoryId: categoryId,
            amount: balance,
            dateTime: DateTime.now(),
            type: 'EXPENSE',
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
      child: Icon(Icons.add),
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
            return Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada transaksi.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
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
