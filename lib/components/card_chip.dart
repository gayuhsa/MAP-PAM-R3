import 'package:flutter/material.dart';

class CardChip extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;

  const CardChip({
    super.key,
    required this.backgroundColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(spacing: 4, children: children),
    );
  }
}
