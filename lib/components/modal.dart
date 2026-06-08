import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                keyboardType: entry.key == 'Isi' ? TextInputType.number : TextInputType.text,
                inputFormatters: entry.key == 'Isi' 
                    ? [FilteringTextInputFormatter.digitsOnly] 
                    : null,
                decoration: InputDecoration(
                  labelText: entry.key,
                  hintText: entry.key == 'Isi' ? 'Masukkan nominal angka (Contoh: 50000)' : null,
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
