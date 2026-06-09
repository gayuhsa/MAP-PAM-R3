import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/dropdown_options.dart';

class Modal extends StatefulWidget {
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
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isDropdownField(String key) {
    return widget.dropdownFields != null &&
        widget.dropdownFields!.containsKey(key);
  }

  bool _isNumericField(String key) {
    return key == 'Isi' || key == 'Jumlah';
  }

  bool _isDateField(String key) {
    return key == 'Tanggal';
  }

  String? _validateField(String key, String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'Field ini wajib diisi.';
    }

    if (_isDateField(key)) {
      if (DateTime.tryParse(trimmed) == null) {
        return 'Format tanggal tidak valid.';
      }
    }

    if (_isNumericField(key)) {
      final parsed = double.tryParse(trimmed);
      if (parsed == null) {
        return 'Masukkan angka yang valid.';
      }
      if (key == 'Jumlah' && parsed <= 0) {
        return 'Jumlah harus lebih besar dari 0.';
      }
      if (key == 'Isi' && parsed < 0) {
        return 'Isi tidak boleh negatif.';
      }
    }

    return null;
  }

  Widget _buildDropdownField(String key, TextEditingController controller) {
    final options = widget.dropdownFields![key]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormField<String>(
        initialValue: controller.text.isNotEmpty ? controller.text : null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Pilih ${key.toLowerCase()} terlebih dahulu.';
          }
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownMenu<String>(
                initialSelection: state.value,
                label: Text(key),
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
                    state.didChange(selectedId);
                  }
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String key, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: _isDateField(key),
        keyboardType: _isNumericField(key)
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: _isNumericField(key)
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: key,
          hintText: _isNumericField(key)
              ? 'Contoh: 50000'
              : (key == 'Nama' ? 'Contoh: Konsumsi' : null),
          border: const OutlineInputBorder(),
          suffixIcon: _isDateField(key)
              ? const Icon(Icons.calendar_today)
              : null,
        ),
        validator: (value) => _validateField(key, value),
        onTap: _isDateField(key)
            ? () async {
                DateTime initialDate =
                    DateTime.tryParse(controller.text) ?? DateTime.now();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.entries.map((entry) {
              final controller = entry.value;

              if (_isDropdownField(entry.key)) {
                return _buildDropdownField(entry.key, controller);
              }

              return _buildTextField(entry.key, controller);
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: const Text('Konfirmasi'),
          onPressed: () {
            final isValid = _formKey.currentState?.validate() ?? false;
            if (isValid) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ],
    );
  }
}
