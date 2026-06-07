import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final String label;
  final ValueChanged<String?> onSelected;

  const Dropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selectedItem,
      label: Text(label),
      dropdownMenuEntries: items.map<DropdownMenuEntry<String>>((String item) {
        return DropdownMenuEntry<String>(value: item, label: item);
      }).toList(),
      onSelected: onSelected,
    );
  }
}
