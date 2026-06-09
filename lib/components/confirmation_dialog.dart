import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  String cancelLabel = 'Batal',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result == true;
}

Future<String?> showDeleteChoiceDialog(
  BuildContext context, {
  required String title,
  required String message,
  String deleteAllLabel = 'Hapus semua transaksi',
  String reassignLabel = 'Simpan transaksi ke default',
  String cancelLabel = 'Batal',
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete_all'),
            child: Text(deleteAllLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('reassign'),
            child: Text(reassignLabel),
          ),
        ],
      );
    },
  );
}
