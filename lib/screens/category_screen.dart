import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/category_card.dart';
import '../components/modal.dart';
import '../components/skeleton.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();

  void _showCategoryModal({Category? category}) async {
    final isEditing = category != null;

    final Map<String, TextEditingController> fields = {
      'Nama': TextEditingController(text: isEditing ? category.name : ''),
    };

    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (context) => Modal(
        title: isEditing ? 'Edit Kategori' : 'Tambah Kategori',
        fields: fields,
      ),
    );

    if (isConfirmed == true) {
      final String name = fields['Nama']!.text.trim();

      if (name.isEmpty) return;

      if (isEditing) {
        category.name = name;
        _categoryService.update(category);
      } else {
        _categoryService.create(Category(name: name));
      }
    }
  }

  Widget _createActionButton() {
    return FloatingActionButton(
      onPressed: () => _showCategoryModal(),
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Kategori',
      actionButton: _createActionButton(),
      content: StreamBuilder<QuerySnapshot>(
        stream: _categoryService.getSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada kategori.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              final Category category = Category.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return CategoryCard(
                category: category,
                modalCallback: _showCategoryModal,
                deleteCallback: _categoryService.delete,
              );
            },
          );
        },
      ),
    );
  }
}
