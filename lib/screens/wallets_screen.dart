import 'package:flutter/material.dart';
import '../components/confirmation_dialog.dart';
import '../components/modal.dart';
import '../components/wallet_card.dart';
import '../components/skeleton.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../theme.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final WalletService _walletService = WalletService();

  void _showWalletModal({Wallet? wallet}) async {
    final isEditing = wallet != null;

    final Map<String, TextEditingController> fields = {
      'Nama': TextEditingController(text: isEditing ? wallet.name : ''),
      'Isi': TextEditingController(
        text: isEditing ? '${wallet.balance}' : null,
      ),
    };

    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Dompet' : 'Tambah Dompet',
        fields: fields,
      ),
    );

    if (isConfirmed == true) {
      final String name = fields['Nama']!.text.trim();
      final double balance = double.tryParse(fields['Isi']!.text.trim()) ?? 0.0;

      if (name.isEmpty) return;

      if (isEditing) {
        final shouldSave = await showConfirmationDialog(
          context,
          title: 'Konfirmasi Edit',
          message: 'Yakin ingin menyimpan perubahan dompet ini?',
          confirmLabel: 'Simpan',
        );
        if (!shouldSave) return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Peringatan: sedang memproses dompet...'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      if (isEditing) {
        debugPrint('WARNING: Edit dompet dimulai.');
        wallet.name = name;
        wallet.balance = balance;
        try {
          await _walletService.update(wallet);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dompet berhasil diubah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengubah dompet!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        debugPrint('WARNING: Input dompet baru dimulai.');
        try {
          await _walletService.create(Wallet(name: name, balance: balance));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dompet berhasil ditambah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menambah dompet!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteWallet(String id) async {
    final option = await showDeleteChoiceDialog(
      context,
      title: 'Hapus Dompet',
      message: 'Pilih cara menangani transaksi yang terkait dengan dompet ini.',
    );
    if (option == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Peringatan: sedang memproses penghapusan dompet...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    debugPrint('WARNING: Penghapusan dompet dimulai.');
    try {
      await _walletService.deleteWithTransactionHandling(
        id,
        deleteTransactions: option == 'delete_all',
        reassignTransactionsToDefault: option == 'reassign',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dompet berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus dompet!'),
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
      onPressed: () => _showWalletModal(),
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Dompet',
      actionButton: _createActionButton(),
      content: StreamBuilder<List<Wallet>>(
        stream: _walletService.getAllByUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada dompet.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              return WalletCard(
                wallet: doc,
                modalCallback: _showWalletModal,
                deleteCallback: _deleteWallet,
              );
            },
          );
        },
      ),
    );
  }
}
