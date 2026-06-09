import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../theme.dart';
import 'card_chip.dart';

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
    String formattedIdr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    ).format(wallet.balance);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                wallet.name,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(formattedIdr),
              Row(
                spacing: 12,
                children: [
                  CardChip(
                    backgroundColor: AppTheme.chipIncome,
                    children: [
                      Icon(Icons.trending_up),
                      Text(
                        'Rp0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CardChip(
                    backgroundColor: AppTheme.chipExpense,
                    children: [
                      Icon(Icons.trending_down),
                      Text(
                        'Rp0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
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
