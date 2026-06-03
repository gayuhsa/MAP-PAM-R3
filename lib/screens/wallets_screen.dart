import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      'Isi': TextEditingController(text: isEditing ? '${wallet.balance}' : ''),
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
        wallet.name = name;
        wallet.balance = balance;
        _walletService.update(wallet);
      } else {
        _walletService.create(Wallet(name: name, balance: balance));
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
      content: StreamBuilder<QuerySnapshot>(
        stream: _walletService.getSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada dompet.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              final Wallet wallet = Wallet.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return WalletCard(
                wallet: wallet,
                modalCallback: _showWalletModal,
                deleteCallback: _walletService.delete,
              );
            },
          );
        },
      ),
    );
  }
}
