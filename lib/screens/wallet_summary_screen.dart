import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../screens/entity_summary_screen.dart';
import '../services/transaction_service.dart';

class WalletSummaryScreen extends StatelessWidget {
  final Wallet wallet;

  const WalletSummaryScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return EntitySummaryScreen(
      title: wallet.name,
      description: wallet.description,
      transactionStream: TransactionService().getByWallet(wallet.id ?? ''),
      summaryForWallet: true,
      otherLabel: 'Kategori',
    );
  }
}
