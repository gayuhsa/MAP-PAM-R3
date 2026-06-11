import 'package:flutter/material.dart';
import '../models/category.dart';
import '../screens/entity_summary_screen.dart';
import '../services/transaction_service.dart';

class CategorySummaryScreen extends StatelessWidget {
  final Category category;

  const CategorySummaryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return EntitySummaryScreen(
      title: category.name,
      description: category.description,
      transactionStream: TransactionService().getByCategory(category.id ?? ''),
      summaryForWallet: false,
      otherLabel: 'Dompet',
    );
  }
}
