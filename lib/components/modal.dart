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

  bool _isOptionalField(String key) {
    return key == 'Keterangan';
  }

  String? _validateField(String key, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty && _isOptionalField(key)) {
      return null;
    }

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
      padding: EdgeInsets.symmetric(vertical: 8),
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
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                ),
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
                  padding: EdgeInsets.only(top: 4),
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
    final isMultiline = key == 'Keterangan';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: _isDateField(key),
        maxLines: isMultiline ? null : 1,
        minLines: isMultiline ? 3 : 1,
        keyboardType: _isNumericField(key)
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: _isNumericField(key)
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,

        decoration: InputDecoration(
          labelText: _isOptionalField(key) ? '$key (opsional)' : key,
          hintText: _hintFor(key),
          border: OutlineInputBorder(),
          suffixIcon: _isDateField(key) ? Icon(Icons.calendar_today) : null,
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

  String? _hintFor(String key) {
    switch (key) {
      case 'Nama Kategori':
        return 'Contoh: Konsumsi';
      case 'Nama':
        return 'Contoh: BCA';
      case 'Jumlah':
        return 'Contoh: 150000';
      case 'Keterangan':
        return 'Keterangan tambahan...';
      case 'Isi':
        return 'Contoh: 50000';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
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
