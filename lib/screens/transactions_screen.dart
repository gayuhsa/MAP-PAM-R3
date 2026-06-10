import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/b_transaction_card.dart';
import '../components/confirmation_dialog.dart';
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

  static const List<DropdownOptions> _typeOptions = [
    DropdownOptions(id: 'INCOME', name: 'Pemasukan'),
    DropdownOptions(id: 'EXPENSE', name: 'Pengeluaran'),
  ];

  double? _parseAmount(String value) {
    final sanitized = value.trim().replaceAll(',', '.');
    if (sanitized.isEmpty) return null;
    return double.tryParse(sanitized);
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed);
  }

  void _showTransactionModal({BTransaction? transaction}) async {
    final categories = await _categoryService.getAllByUserId().first;
    final wallets = await _walletService.getAllByUserId().first;
    final isEditing = transaction != null;

    final validWallets = wallets
        .where((w) => w.id != null && w.id!.isNotEmpty)
        .toList();
    final validCategories = categories
        .where((c) => c.id != null && c.id!.isNotEmpty)
        .toList();

    if (validWallets.isEmpty || validCategories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pastikan ada dompet dan kategori terlebih dahulu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String initialWalletId = isEditing ? transaction.walletId : '';
    String initialCategoryId = isEditing ? transaction.categoryId : '';

    if (!validWallets.any((w) => w.id == initialWalletId)) {
      initialWalletId = validWallets.first.id!;
    }
    if (!validCategories.any((c) => c.id == initialCategoryId)) {
      initialCategoryId = validCategories.first.id!;
    }

    final Map<String, TextEditingController> fields = {
      'Tanggal': TextEditingController(
        text: isEditing
            ? DateFormat('yyyy-MM-dd').format(transaction.dateTime)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
      'Dompet': TextEditingController(text: initialWalletId),
      'Kategori': TextEditingController(text: initialCategoryId),
      'Jumlah': TextEditingController(
        text: isEditing ? '${transaction.amount.toInt()}' : '',
      ),
      'Jenis': TextEditingController(
        text: isEditing ? transaction.type : 'EXPENSE',
      ),
      'Keterangan': TextEditingController(
        text: isEditing ? transaction.note : '',
      ),
    };

    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
        fields: fields,
        dropdownFields: {
          'Dompet': validWallets
              .map((w) => DropdownOptions(id: w.id!, name: w.name))
              .toList(),
          'Kategori': validCategories
              .map((c) => DropdownOptions(id: c.id!, name: c.name))
              .toList(),
          'Jenis': _typeOptions,
        },
      ),
    );

    if (isConfirmed != true) return;

    final String walletId = fields['Dompet']!.text.trim();
    final String categoryId = fields['Kategori']!.text.trim();
    final double? amount = _parseAmount(fields['Jumlah']!.text.trim());
    final String type = fields['Jenis']!.text.trim().isEmpty
        ? 'EXPENSE'
        : fields['Jenis']!.text.trim().toUpperCase();
    final DateTime? dateTime = _parseDate(fields['Tanggal']!.text.trim());

    if (walletId.isEmpty ||
        categoryId.isEmpty ||
        amount == null ||
        amount <= 0 ||
        dateTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Isi semua field dengan benar: dompet, kategori, tanggal, dan jumlah > 0.',
            ),
          ),
        );
      }
      return;
    }

    final BTransaction updatedTransaction = BTransaction(
      id: transaction?.id,
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      dateTime: dateTime,
      type: type,
      note: fields['Keterangan']!.text.trim(),
    );

    if (isEditing) {
      final confirmEdit = await showConfirmationDialog(
        context,
        title: 'Konfirmasi Edit',
        message: 'Yakin ingin menyimpan perubahan transaksi ini?',
      );
      if (!confirmEdit) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Peringatan: sedang memproses perubahan transaksi...',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      try {
        await _transactionService.updateWithWalletAdjustment(
          transaction,
          updatedTransaction,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi berhasil diubah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah transaksi!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Peringatan: sedang memproses penambahan transaksi...',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      try {
        await _transactionService.createWithWalletAdjustment(
          updatedTransaction,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi berhasil ditambah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
    if (id.isEmpty) return;

    final confirmDelete = await showConfirmationDialog(
      context,
      title: 'Konfirmasi Hapus',
      message: 'Yakin ingin menghapus transaksi ini?',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
    );
    if (!confirmDelete) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sedang memproses penghapusan transaksi...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    try {
      final tx = await _transactionService.getById(id);
      if (tx != null) {
        await _transactionService.deleteWithWalletAdjustment(tx);
      } else {
        await _transactionService.delete(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus transaksi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _createActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.button2,
      foregroundColor: AppTheme.textInverted,
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
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Terjadi error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada transaksi.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: BTransactionCard(
                  transaction: doc,
                  modalCallback: ({BTransaction? transaction}) =>
                      _showTransactionModal(transaction: transaction),
                  deleteCallback: _deleteTransaction,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
