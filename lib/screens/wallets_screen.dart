import 'package:flutter/material.dart';
import '../components/confirmation_dialog.dart';
import '../components/modal.dart';
import '../components/wallet_card.dart';
import '../components/skeleton.dart';
import '../models/wallet.dart';
import '../screens/wallet_summary_screen.dart';
import '../services/wallet_service.dart';
import '../theme.dart';
import '../utils/string_utils.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showWalletModal({Wallet? wallet}) async {
    final isEditing = wallet != null;

    final Map<String, TextEditingController> fields = {
      'Nama': TextEditingController(text: isEditing ? wallet.name : ''),
      'Jumlah': TextEditingController(
        text: isEditing ? '${wallet.balance}' : null,
      ),
      'Keterangan': TextEditingController(
        text: isEditing ? wallet.description : '',
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
      final String name = normalizeEntityName(fields['Nama']!.text);
      final double balance =
          double.tryParse(fields['Jumlah']!.text.trim()) ?? 0.0;

      if (name.isEmpty) return;

      if (await _walletService.existsWithName(
        name,
        excludeId: isEditing ? wallet.id : null,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dompet dengan nama "$name" telah dibuat.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (isEditing) {
        final shouldSave = await showConfirmationDialog(
          // ignore: use_build_context_synchronously
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
        wallet.name = name;
        wallet.description = fields['Keterangan']!.text.trim();
        wallet.balance = balance;
        // preserve initialBalance on edit
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
        try {
          await _walletService.create(
            Wallet(
              name: name,
              description: fields['Keterangan']!.text.trim(),
              balance: balance,
              initialBalance: balance,
            ),
          );
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
      backgroundColor: AppTheme.button2,
      foregroundColor: AppTheme.textInverted,
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

          final filteredDocs = docs.where((wallet) {
            final query = _searchQuery.toLowerCase();
            return wallet.name.toLowerCase().contains(query) ||
                wallet.description.toLowerCase().contains(query);
          }).toList();

          final double totalBalance = filteredDocs.fold(
            0,
            (sum, w) => sum + w.balance,
          );

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari dompet berdasarkan nama atau keterangan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.button2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saldo',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(child: Text('Tidak ada dompet yang cocok.'))
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                        itemCount: filteredDocs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final doc = filteredDocs[index];
                          return WalletCard(
                            wallet: doc,
                            modalCallback: _showWalletModal,
                            deleteCallback: _deleteWallet,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WalletSummaryScreen(wallet: doc),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
