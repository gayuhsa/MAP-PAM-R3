import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/skeleton.dart';
import '../models/budget_account.dart';
import '../models/shopping_record.dart';
import '../services/budget_account_service.dart';
import '../services/shopping_record_service.dart';
import '../theme.dart';
import 'shopping_record_screen.dart';

class BudgetRealizationScreen extends StatelessWidget {
  const BudgetRealizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetAccountService accountService = BudgetAccountService();
    final ShoppingRecordService recordService = ShoppingRecordService();

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Skeleton(
      title: 'Realisasi Anggaran',
      content: StreamBuilder<List<BudgetAccount>>(
        stream: accountService.getAll(),
        builder: (context, accountSnap) {
          if (accountSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = accountSnap.data ?? [];

          return StreamBuilder<List<ShoppingRecord>>(
            stream: recordService.getAll(),
            builder: (context, recordSnap) {
              if (recordSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = recordSnap.data ?? [];

              // ─── Hitung agregat ──────────────────────────────────────
              final totalAnggaran = accounts.fold<double>(
                0,
                (s, a) => s + a.jumlah,
              );
              final totalPengeluaran = records.fold<double>(
                0,
                (s, r) => s + r.jumlahTotal,
              );
              final sisaAnggaran = totalAnggaran - totalPengeluaran;
              final persen = totalAnggaran > 0
                  ? (totalPengeluaran / totalAnggaran * 100)
                        .clamp(0, 100)
                        .toDouble()
                  : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Kartu ringkasan (3 kartu) ─────────────────────
                    _buildSummaryRow(
                      context,
                      totalAnggaran: totalAnggaran,
                      sisaAnggaran: sisaAnggaran,
                      persen: persen,
                      currencyFormat: currencyFormat,
                    ),
                    const SizedBox(height: 16),

                    // ─── Progress bar keseluruhan ──────────────────────
                    _buildOverallProgress(
                      persen,
                      currencyFormat,
                      totalPengeluaran,
                      totalAnggaran,
                    ),
                    const SizedBox(height: 16),

                    // ─── Header tabel ──────────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.bar_chart, color: AppTheme.button),
                        const SizedBox(width: 8),
                        const Text(
                          'Daftar Realisasi per Akun',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.text,
                          ),
                        ),
                        const Spacer(),
                        // Shortcut ke halaman Catatan Belanja
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShoppingRecordScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Catat Belanja'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.button,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ─── Tabel realisasi ───────────────────────────────
                    accounts.isEmpty
                        ? const _EmptyState(message: 'Belum ada akun anggaran.')
                        : _buildRealizationTable(
                            accounts,
                            records,
                            currencyFormat,
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─── 3 kartu ringkasan ────────────────────────────────────────────────────
  Widget _buildSummaryRow(
    BuildContext context, {
    required double totalAnggaran,
    required double sisaAnggaran,
    required double persen,
    required NumberFormat currencyFormat,
  }) {
    final isOver = sisaAnggaran < 0;
    final statusLabel = isOver
        ? 'Melebihi'
        : persen >= 100
        ? 'Habis'
        : 'Aman';
    final statusColor = isOver
        ? AppTheme.buttonDanger
        : persen >= 80
        ? Colors.orange
        : AppTheme.button;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryCard(
          icon: Icons.account_balance_wallet,
          label: 'Total Anggaran',
          value: currencyFormat.format(totalAnggaran),
          color: AppTheme.button,
        ),
        _SummaryCard(
          icon: Icons.savings_outlined,
          label: sisaAnggaran < 0 ? 'Kelebihan Pakai' : 'Sisa Anggaran',
          value: currencyFormat.format(sisaAnggaran.abs()),
          color: isOver ? AppTheme.buttonDanger : AppTheme.button,
        ),
        _SummaryCard(
          icon: isOver
              ? Icons.warning_amber_rounded
              : Icons.check_circle_outline,
          label: 'Status',
          value: statusLabel,
          color: statusColor,
          isStatus: true,
        ),
      ],
    );
  }

  // ─── Progress bar keseluruhan ─────────────────────────────────────────────
  Widget _buildOverallProgress(
    double persen,
    NumberFormat fmt,
    double pengeluaran,
    double anggaran,
  ) {
    final color = persen > 100
        ? AppTheme.buttonDanger
        : persen >= 80
        ? Colors.orange
        : AppTheme.button;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Realisasi Keseluruhan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${persen.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (persen / 100).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: AppTheme.subcontainer,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${fmt.format(pengeluaran)} dari ${fmt.format(anggaran)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.text),
          ),
        ],
      ),
    );
  }

  // ─── Tabel realisasi per akun anggaran ───────────────────────────────────
  Widget _buildRealizationTable(
    List<BudgetAccount> accounts,
    List<ShoppingRecord> records,
    NumberFormat fmt,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        color: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTheme.container),
            dataRowColor: WidgetStateProperty.all(AppTheme.card),
            columnSpacing: 16,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
              fontSize: 13,
            ),
            columns: const [
              DataColumn(label: Text('Nama Akun')),
              DataColumn(label: Text('Anggaran'), numeric: true),
              DataColumn(label: Text('Pengeluaran'), numeric: true),
              DataColumn(label: Text('Sisa/Lebih'), numeric: true),
              DataColumn(label: Text('Realisasi')),
              DataColumn(label: Text('Status')),
            ],
            rows: accounts.map((account) {
              // jumlahkan pengeluaran yang terkait akun ini
              final pengeluaran = records
                  .where((r) => r.budgetAccountId == account.id)
                  .fold<double>(0, (s, r) => s + r.jumlahTotal);
              final sisa = account.jumlah - pengeluaran;
              final pct = account.jumlah > 0
                  ? (pengeluaran / account.jumlah * 100).clamp(0, 999)
                  : 0.0;
              final isOver = sisa < 0;

              final statusColor = isOver
                  ? AppTheme.buttonDanger
                  : pct >= 80
                  ? Colors.orange
                  : AppTheme.button;
              final statusLabel = isOver
                  ? 'Melebihi'
                  : pct >= 80
                  ? 'Mendekati'
                  : 'Aman';

              return DataRow(
                cells: [
                  // Nama Akun
                  DataCell(
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Anggaran
                  DataCell(
                    Text(
                      fmt.format(account.jumlah),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  // Pengeluaran
                  DataCell(
                    Text(
                      fmt.format(pengeluaran),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  // Sisa / Lebih
                  DataCell(
                    Text(
                      (isOver ? '−' : '') + fmt.format(sisa.abs()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOver ? AppTheme.buttonDanger : AppTheme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Progress bar mini + persen
                  DataCell(
                    SizedBox(
                      width: 110,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (pct / 100).clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: AppTheme.subcontainer,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status badge
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        // ignore: deprecated_member_use
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Kartu ringkasan ──────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isStatus;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.text),
          ),
          const SizedBox(height: 4),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, style: const TextStyle(color: AppTheme.text)),
      ),
    );
  }
}
