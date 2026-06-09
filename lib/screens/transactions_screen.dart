import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Dropdown opsi jenis transaksi
  static const List<DropdownOptions> _typeOptions = [
    DropdownOptions(id: 'INCOME', name: 'Pemasukan'),
    DropdownOptions(id: 'EXPENSE', name: 'Pengeluaran'),
  ];

  //  Hitung delta saldo berdasarkan jenis transaksi
  double _computeDelta(String type, double amount) {
    return type.toUpperCase() == 'INCOME' ? amount : -amount;
  }

  void _showTransactionModal({BTransaction? transaction}) async {
    final categories = await _categoryService.getAllByUserId().first;
    final wallets = await _walletService.getAllByUserId().first;
    final isEditing = transaction != null;

    final Map<String, TextEditingController> fields = {
      'Tanggal': TextEditingController(
        text: isEditing
            ? DateFormat('yyyy-MM-dd').format(transaction.dateTime)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
      'Dompet': TextEditingController(
        text: isEditing ? transaction.walletId : '',
      ),
      'Kategori': TextEditingController(
        text: isEditing ? transaction.categoryId : '',
      ),
      'Jumlah': TextEditingController(
        text: isEditing ? '${transaction.amount.toInt()}' : '',
      ),
      // Default ke 'EXPENSE', bukan string kosong
      'Jenis': TextEditingController(
        text: isEditing ? transaction.type : 'EXPENSE',
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
          // Field Jenis sekarang dropdown INCOME / EXPENSE
          'Jenis': _typeOptions,
        },
      ),
    );

    if (isConfirmed != true) return;

    final String walletId = fields['Dompet']!.text.trim();
    final String categoryId = fields['Kategori']!.text.trim();
    final double amount = double.tryParse(fields['Jumlah']!.text.trim()) ?? 0.0;
    final String type = fields['Jenis']!.text.trim().isEmpty
        ? 'EXPENSE'
        : fields['Jenis']!.text.trim().toUpperCase();
    final DateTime dateTime =
        DateTime.tryParse(fields['Tanggal']!.text.trim()) ?? DateTime.now();

    // Validasi: walletId, categoryId, dan amount > 0 wajib diisi
    if (walletId.isEmpty || categoryId.isEmpty || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Isi semua field dan pastikan jumlah lebih dari 0.'),
          ),
        );
      }
      return;
    }

    if (isEditing) {
      try {
        // Edit: rollback saldo lama → terapkan saldo baru
        final double oldDelta = _computeDelta(
          transaction.type,
          transaction.amount,
        );

        // Rollback saldo lama di wallet lama
        await _walletService.adjustBalance(transaction.walletId, -oldDelta);

        // Terapkan saldo baru di wallet baru (mungkin sama / beda)
        await _walletService.adjustBalance(
          walletId,
          _computeDelta(type, amount),
        );

        transaction.walletId = walletId;
        transaction.categoryId = categoryId;
        transaction.amount = amount;
        transaction.type = type;
        transaction.dateTime = dateTime;
        await _transactionService.update(transaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil diubah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error editing transaction: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah transaksi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      try {
        // Create: update saldo wallet
        await _walletService.adjustBalance(
          walletId,
          _computeDelta(type, amount),
        );
        final docRef = await _transactionService.create(
          BTransaction(
            walletId: walletId,
            categoryId: categoryId,
            amount: amount,
            dateTime: dateTime,
            type: type,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi berhasil ditambah! ID: ${docRef.id}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error creating transaction: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambah transaksi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      // Cari transaksi dari stream saat ini
      final allTx = await _transactionService.getAllByUserId().first;
      final tx = allTx.where((t) => t.id == id).firstOrNull;

      if (tx != null) {
        await _walletService.adjustBalance(
          tx.walletId,
          -_computeDelta(tx.type, tx.amount),
        );
      }

      await _transactionService.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus transaksi: $e'),
            backgroundColor: Colors.red,
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
            debugPrint("Transactions Stream Error: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Terjadi error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              return ListTile(
                title: Text(doc.id ?? "No ID"),
                subtitle: Text(doc.amount.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
