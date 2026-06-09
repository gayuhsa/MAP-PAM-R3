import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/dropdown_options.dart';

class Modal extends StatelessWidget {
  final Map<String, TextEditingController> fields;
  final String title;
  final Map<String, List<DropdownOptions>>? dropdownFields;

  const Modal({
    super.key,
    required this.fields,
    this.title = 'Modal',
    this.dropdownFields,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields.entries.map((entry) {
            final TextEditingController controller = entry.value;

            if (entry.key == 'Tanggal') {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime initialDate =
                        DateTime.tryParse(controller.text) ?? DateTime.now();
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      controller.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              );
            }

            if (dropdownFields != null &&
                dropdownFields!.containsKey(entry.key)) {
              final List<DropdownOptions> options = dropdownFields![entry.key]!;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: DropdownMenu<String>(
                  initialSelection: controller.text.isNotEmpty
                      ? controller.text
                      : null,
                  label: Text(entry.key),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: options.map((DropdownOptions option) {
                    return DropdownMenuEntry<String>(
                      value: option.id,
                      label: option.name,
                    );
                  }).toList(),
                  onSelected: (String? selectedId) {
                    if (selectedId != null) {
                      controller.text = selectedId;
                    }
                  },
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: entry.value,
                keyboardType: (entry.key == 'Isi' || entry.key == 'Jumlah')
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: (entry.key == 'Isi' || entry.key == 'Jumlah')
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                decoration: InputDecoration(
                  labelText: entry.key,
                  hintText: entry.key == 'Isi' || entry.key == 'Jumlah'
                      ? 'Contoh: 50000'
                      : (entry.key == 'Nama' ? 'Contoh: Konsumsi' : null),
                  border: OutlineInputBorder(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: Text('Konfirmasi'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
