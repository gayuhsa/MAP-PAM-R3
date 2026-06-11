import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/skeleton.dart';
import '../models/b_transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../services/category_service.dart';
import '../services/wallet_service.dart';
import '../theme.dart';

class EntitySummaryScreen extends StatefulWidget {
  final String title;
  final String description;
  final Stream<List<BTransaction>> transactionStream;
  final bool summaryForWallet;
  final String otherLabel;
  final double? startingValue;

  const EntitySummaryScreen({
    super.key,
    required this.title,
    required this.description,
    required this.transactionStream,
    required this.summaryForWallet,
    required this.otherLabel,
    this.startingValue,
  });

  @override
  State<EntitySummaryScreen> createState() => _EntitySummaryScreenState();
}

class _EntitySummaryScreenState extends State<EntitySummaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Tanggal';

  static const List<String> _filterOptions = ['Tanggal', 'Bulan', 'Tahun'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(BTransaction transaction, String query, String otherName) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final note = transaction.note.toLowerCase();
    final dateText = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(transaction.dateTime).toLowerCase();
    final monthText = DateFormat(
      'MMMM',
      'id_ID',
    ).format(transaction.dateTime).toLowerCase();
    final yearText = transaction.dateTime.year.toString();
    final typeText = transaction.type.toLowerCase();

    return otherName.toLowerCase().contains(lowerQuery) ||
        note.contains(lowerQuery) ||
        dateText.contains(lowerQuery) ||
        monthText.contains(lowerQuery) ||
        yearText.contains(lowerQuery) ||
        typeText.contains(lowerQuery);
  }

  String _groupKey(BTransaction transaction) {
    switch (_selectedFilter) {
      case 'Bulan':
        return DateFormat('MMMM yyyy', 'id_ID').format(transaction.dateTime);
      case 'Tahun':
        return transaction.dateTime.year.toString();
      default:
        return DateFormat('dd MMM yyyy', 'id_ID').format(transaction.dateTime);
    }
  }

  List<MapEntry<String, double>> _groupTransactions(
    List<BTransaction> transactions,
  ) {
    final Map<String, double> grouped = {};
    for (final tx in transactions) {
      final key = _groupKey(tx);
      grouped[key] =
          (grouped[key] ?? 0) +
          (tx.type.toUpperCase() == 'INCOME' ? tx.amount : -tx.amount);
    }
    final entries = grouped.entries.toList();
    entries.sort((a, b) {
      try {
        if (_selectedFilter == 'Tahun') {
          return int.parse(a.key).compareTo(int.parse(b.key));
        }
        if (_selectedFilter == 'Bulan') {
          return DateFormat('MMMM yyyy', 'id_ID')
              .parse(a.key, true)
              .compareTo(DateFormat('MMMM yyyy', 'id_ID').parse(b.key, true));
        }
      } catch (_) {}
      return DateFormat('dd MMM yyyy', 'id_ID')
          .parse(a.key, true)
          .compareTo(DateFormat('dd MMM yyyy', 'id_ID').parse(b.key, true));
    });
    return entries;
  }

  Widget _buildChart(List<MapEntry<String, double>> entries) {
    if (entries.isEmpty && widget.startingValue == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text('Tidak ada data untuk grafik.'),
      );
    }

    final labels = widget.startingValue != null
        ? ['Saldo Awal', ...entries.map((e) => e.key)]
        : entries.map((e) => e.key).toList();

    final cumulativeValues = <double>[];
    if (widget.startingValue != null) {
      double current = widget.startingValue!;
      cumulativeValues.add(current);
      for (final entry in entries) {
        current += entry.value.toDouble();
        cumulativeValues.add(current);
      }
    } else {
      cumulativeValues.addAll(entries.map((e) => e.value.toDouble()));
    }

    final spots = List.generate(
      cumulativeValues.length,
      (index) => FlSpot(index.toDouble(), cumulativeValues[index]),
    );

    final double minY = min(0.0, cumulativeValues.reduce(min));
    final double maxY = cumulativeValues.reduce(max);
    final labelInterval = max(1, (labels.length / 4).ceil());
    final double yInterval = max(1.0, (maxY - minY) / 4);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval.toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % labelInterval != 0 &&
                      index != labels.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(labels[index], style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, interval: 1.0),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, interval: 1.0),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  final label = NumberFormat.compact(
                    locale: 'id_ID',
                  ).format(value.abs());
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('Rp$label', style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minY: minY,
          maxY: (maxY == minY ? maxY + 1.0 : maxY),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: AppTheme.button2,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    try {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(amount);
    } catch (_) {
      return 'Rp${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildTransactionItem(BTransaction transaction, String otherName) {
    final isIncome = transaction.type.toUpperCase() == 'INCOME';
    final dateText = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(transaction.dateTime);
    final relationLabel = widget.summaryForWallet ? 'Kategori' : 'Dompet';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.type.toUpperCase() == 'INCOME'
                    ? 'Pemasukan'
                    : 'Pengeluaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppTheme.chipIncome : AppTheme.chipExpense,
                ),
              ),
              Text(
                _formatCurrency(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? AppTheme.chipTextIncome
                      : AppTheme.chipTextExpense,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            dateText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 8),
          Text('$relationLabel: $otherName', style: TextStyle(fontSize: 14)),
          if (transaction.note.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(transaction.note, style: TextStyle(color: Colors.grey[700])),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String descriptionText = widget.description.isNotEmpty
        ? widget.description
        : 'Belum ada deskripsi.';

    return Skeleton(
      title: widget.title,
      actionButton: null,
      content: StreamBuilder<List<BTransaction>>(
        stream: widget.transactionStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error memuat transaksi.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          return StreamBuilder<List<dynamic>>(
            stream: widget.summaryForWallet
                ? CategoryService().getAllByUserId().map(
                    (list) => list as List<dynamic>,
                  )
                : WalletService().getAllByUserId().map(
                    (list) => list as List<dynamic>,
                  ),
            builder: (context, namesSnapshot) {
              if (namesSnapshot.hasError) {
                return Center(
                  child: Text('Terjadi error memuat data referensi.'),
                );
              }
              if (!namesSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final otherNames = <String, String>{};
              for (final item in namesSnapshot.data!) {
                if (item is Wallet) {
                  otherNames[item.id ?? ''] = item.name;
                } else if (item is Category) {
                  otherNames[item.id ?? ''] = item.name;
                }
              }

              final filteredTransactions = transactions.where((transaction) {
                return _matchesQuery(
                  transaction,
                  _searchQuery,
                  otherNames[transaction.walletId] ??
                      otherNames[transaction.categoryId] ??
                      '',
                );
              }).toList();

              final totalIncome = filteredTransactions
                  .where((t) => t.type == 'INCOME')
                  .fold(0.0, (sum, t) => sum + t.amount);
              final totalExpense = filteredTransactions
                  .where((t) => t.type == 'EXPENSE')
                  .fold(0.0, (sum, t) => sum + t.amount);

              final chartEntries = _groupTransactions(filteredTransactions);

              return ListView(
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          descriptionText,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          style: TextStyle(color: AppTheme.text),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Cari transaksi dalam ringkasan...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim();
                            });
                          },
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: _filterOptions.map((filter) {
                            final selected = _selectedFilter == filter;
                            return ChoiceChip(
                              label: Text(filter),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.chipIncome,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pemasukan',
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(totalIncome),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.chipExpense,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengeluaran',
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(totalExpense),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: _buildChart(chartEntries),
                  ),
                  SizedBox(height: 12),
                  if (filteredTransactions.isEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: Text(
                          'Tidak ada transaksi untuk ringkasan ini.',
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ] else ...[
                    ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        final otherName = widget.summaryForWallet
                            ? (otherNames[transaction.categoryId] ??
                                'Kategori tidak ditemukan')
                            : (otherNames[transaction.walletId] ??
                                'Dompet tidak ditemukan');
                        return _buildTransactionItem(
                          transaction,
                          otherName,
                        );
                      },
                    ),
                    SizedBox(height: 12),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
