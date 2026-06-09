import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/modal.dart';
import '../components/skeleton.dart';
import '../models/budget_account.dart';
import '../models/dropdown_options.dart';
import '../models/shopping_record.dart';
import '../services/budget_account_service.dart';
import '../services/shopping_record_service.dart';
import '../theme.dart';

class ShoppingRecordScreen extends StatefulWidget {
  const ShoppingRecordScreen({super.key});

  @override
  State<ShoppingRecordScreen> createState() => _ShoppingRecordScreenState();
}

class _ShoppingRecordScreenState extends State<ShoppingRecordScreen> {
  final ShoppingRecordService _service = ShoppingRecordService();
  final BudgetAccountService _budgetAccountService = BudgetAccountService();

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  // ─── Dialog tambah / edit ─────────────────────────────────────────────────
  Future<void> _showRecordModal({ShoppingRecord? record}) async {
    // Ambil daftar akun anggaran untuk dropdown
    final accounts = await _budgetAccountService.getAll().first;

    if (!mounted) return;

    final isEditing = record != null;

    final tanggalCtrl = TextEditingController(
      text: isEditing
          ? DateFormat('yyyy-MM-dd').format(record.tanggal)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final akunCtrl = TextEditingController(
      text: isEditing ? record.budgetAccountId : '',
    );
    final volumeCtrl = TextEditingController(
      text: isEditing ? record.volume.toStringAsFixed(0) : '',
    );
    final satuanCtrl = TextEditingController(
      text: isEditing ? record.satuan : '',
    );
    final jumlahCtrl = TextEditingController(
      text: isEditing ? record.jumlahTotal.toStringAsFixed(0) : '',
    );
    final keteranganCtrl = TextEditingController(
      text: isEditing ? record.keterangan : '',
    );
    final buktiCtrl = TextEditingController(
      text: isEditing ? record.buktiPengeluaran : '',
    );

    final Map<String, TextEditingController> fields = {
      'Tanggal': tanggalCtrl,
      'Akun Anggaran': akunCtrl,
      'Volume': volumeCtrl,
      'Satuan': satuanCtrl,
      'Jumlah Total': jumlahCtrl,
      'Keterangan': keteranganCtrl,
      'Bukti Pengeluaran': buktiCtrl,
    };

    final dropdownOptions = {
      'Akun Anggaran': accounts
          .map((a) => DropdownOptions(id: a.id!, name: a.name))
          .toList(),
    };

    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Catatan Belanja' : 'Tambah Catatan Belanja',
        fields: fields,
        dropdownFields: dropdownOptions,
      ),
    );

    if (confirmed == true) {
      final newRecord = ShoppingRecord(
        id: record?.id,
        tanggal: DateTime.tryParse(tanggalCtrl.text) ?? DateTime.now(),
        budgetAccountId: akunCtrl.text.trim(),
        volume: double.tryParse(volumeCtrl.text.trim()) ?? 0,
        satuan: satuanCtrl.text.trim(),
        jumlahTotal: double.tryParse(jumlahCtrl.text.trim()) ?? 0,
        keterangan: keteranganCtrl.text.trim(),
        buktiPengeluaran: buktiCtrl.text.trim(),
      );

      if (isEditing) {
        await _service.update(newRecord);
      } else {
        await _service.create(newRecord);
      }
    }
  }

  // ─── Konfirmasi hapus ─────────────────────────────────────────────────────
  Future<void> _confirmDelete(String id) async {
    final bool? ok = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan belanja ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonDanger,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) await _service.delete(id);
  }

  // ─── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Catatan Belanja',
      actionButton: FloatingActionButton(
        backgroundColor: AppTheme.card,
        foregroundColor: AppTheme.text,
        onPressed: () => _showRecordModal(),
        child: const Icon(Icons.add),
      ),
      content: StreamBuilder<List<BudgetAccount>>(
        stream: _budgetAccountService.getAll(),
        builder: (context, accountSnap) {
          final accounts = accountSnap.data ?? [];

          return StreamBuilder<List<ShoppingRecord>>(
            stream: _service.getAll(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Center(child: Text('Terjadi error. Coba lagi.'));
              }

              final records = snap.data ?? [];

              if (records.isEmpty) {
                return const Center(child: Text('Belum ada catatan belanja.'));
              }

              return Column(
                children: [
                  // ─── Ringkasan total ──────────────────────────────────
                  _SummaryBar(
                    total: records.fold(0, (s, r) => s + r.jumlahTotal),
                    count: records.length,
                    currencyFormat: _currencyFormat,
                  ),
                  // ─── Tabel (scrollable horizontal + vertikal) ─────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildTable(records, accounts),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTable(
    List<ShoppingRecord> records,
    List<BudgetAccount> accounts,
  ) {
    return Card(
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
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Akun Anggaran')),
            DataColumn(label: Text('Volume'), numeric: true),
            DataColumn(label: Text('Satuan')),
            DataColumn(label: Text('Jumlah Total'), numeric: true),
            DataColumn(label: Text('Keterangan')),
            DataColumn(label: Text('Bukti')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: records.map((r) {
            final accountName =
                accounts
                    .where((a) => a.id == r.budgetAccountId)
                    .map((a) => a.name)
                    .firstOrNull ??
                r.budgetAccountId;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    _dateFormat.format(r.tanggal),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(accountName, style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text(
                    r.volume.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(Text(r.satuan, style: const TextStyle(fontSize: 12))),
                DataCell(
                  Text(
                    _currencyFormat.format(r.jumlahTotal),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      r.keterangan,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  r.buktiPengeluaran.isEmpty
                      ? const Text('-', style: TextStyle(fontSize: 12))
                      : Tooltip(
                          message: r.buktiPengeluaran,
                          child: const Icon(
                            Icons.attach_file,
                            size: 18,
                            color: AppTheme.button,
                          ),
                        ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol edit
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: AppTheme.editButton,
                        tooltip: 'Edit',
                        onPressed: () => _showRecordModal(record: r),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      // Tombol hapus
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        color: AppTheme.trashButton,
                        tooltip: 'Hapus',
                        onPressed: () => _confirmDelete(r.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Widget ringkasan di atas tabel ──────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final double total;
  final int count;
  final NumberFormat currencyFormat;

  const _SummaryBar({
    required this.total,
    required this.count,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.container,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.receipt_long,
            label: 'Total Transaksi',
            value: '$count catatan',
          ),
          const Spacer(),
          _StatChip(
            icon: Icons.payments_outlined,
            label: 'Total Pengeluaran',
            value: currencyFormat.format(total),
            valueColor: AppTheme.buttonDanger,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.button, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.text),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
