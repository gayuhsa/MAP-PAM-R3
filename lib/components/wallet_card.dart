import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../services/transaction_service.dart';
import '../theme.dart';
import 'card_chip.dart';

class WalletCard extends StatefulWidget {
  final Wallet wallet;
  final void Function({Wallet? wallet}) modalCallback;
  final void Function(String) deleteCallback;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.modalCallback,
    required this.deleteCallback,
    this.onTap,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  late final TransactionService _transactionService;
  late Stream<Map<String, double>> _summaryStream;

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService();
    _summaryStream = _buildSummaryStream();
  }

  @override
  void didUpdateWidget(covariant WalletCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wallet.id != widget.wallet.id) {
      _summaryStream = _buildSummaryStream();
    }
  }

  Stream<Map<String, double>> _buildSummaryStream() {
    return _transactionService.getAllByUserId().map((transactions) {
      double income = 0;
      double expense = 0;
      for (final tx in transactions) {
        if (tx.walletId == widget.wallet.id) {
          if (tx.type.toUpperCase() == 'INCOME') {
            income += tx.amount;
          } else {
            expense += tx.amount;
          }
        }
      }
      return {'income': income, 'expense': expense};
    });
  }

  String _formatCurrency(double value) {
    try {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(value);
    } catch (_) {
      return 'Rp${value.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedBalance = _formatCurrency(widget.wallet.balance);

    return StreamBuilder<Map<String, double>>(
      stream: _summaryStream,
      builder: (context, snapshot) {
        final income = snapshot.data?['income'] ?? 0;
        final expense = snapshot.data?['expense'] ?? 0;

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              border: Border.all(color: AppTheme.cardBorder, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.wallet.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            formattedBalance,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.wallet.description.isNotEmpty) ...[
                            SizedBox(height: 6),
                            Text(
                              widget.wallet.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.editButton,
                        foregroundColor: AppTheme.textInverted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          widget.modalCallback(wallet: widget.wallet),
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
                      onPressed: () =>
                          widget.deleteCallback(widget.wallet.id ?? ''),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CardChip(
                        backgroundColor: AppTheme.chipIncome,
                        children: [
                          Icon(Icons.trending_up, size: 16),
                          Text(
                            _formatCurrency(income),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CardChip(
                        backgroundColor: AppTheme.chipExpense,
                        children: [
                          Icon(Icons.trending_down, size: 16),
                          Text(
                            _formatCurrency(expense),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
