import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "../models/category.dart";
import '../services/transaction_service.dart';
import '../theme.dart';
import 'card_chip.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final void Function({Category? category}) modalCallback;
  final void Function(String) deleteCallback;

  const CategoryCard({
    super.key,
    required this.category,
    required this.modalCallback,
    required this.deleteCallback,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late final TransactionService _transactionService;
  late Stream<Map<String, double>> _summaryStream;

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService();
    _summaryStream = _buildSummaryStream();
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _summaryStream = _buildSummaryStream();
    }
  }

  Stream<Map<String, double>> _buildSummaryStream() {
    return _transactionService.getAllByUserId().map((transactions) {
      double income = 0;
      double expense = 0;
      for (final tx in transactions) {
        if (tx.categoryId == widget.category.id) {
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
    return StreamBuilder<Map<String, double>>(
      stream: _summaryStream,
      builder: (context, snapshot) {
        final income = snapshot.data?['income'] ?? 0;
        final expense = snapshot.data?['expense'] ?? 0;

        return Container(
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
                          widget.category.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ringkasan transaksi kategori',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
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
                        widget.modalCallback(category: widget.category),
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
                        widget.deleteCallback(widget.category.id ?? ''),
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
        );
      },
    );
  }
}
