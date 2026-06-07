import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../theme.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final void Function({Wallet? wallet}) modalCallback;
  final void Function(String) deleteCallback;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.modalCallback,
    required this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wallet.name,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Rp${wallet.balance}'),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.edit),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.editButton,
              foregroundColor: AppTheme.textInverted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => modalCallback(wallet: wallet),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.trashButton,
              foregroundColor: AppTheme.textInverted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => deleteCallback(wallet.id ?? ''),
          ),
        ],
      ),
    );
  }
}
