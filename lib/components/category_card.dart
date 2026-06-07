import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final void Function({Category? category}) modalCallback;
  final void Function(String) deleteCallback;

  const CategoryCard({
    super.key,
    required this.category,
    required this.modalCallback,
    required this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            category.name,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.edit),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.editButton,
              foregroundColor: AppTheme.textInverted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => modalCallback(category: category),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.trashButton,
              foregroundColor: AppTheme.textInverted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => deleteCallback(category.id ?? ''),
          ),
        ],
      ),
    );
  }
}
