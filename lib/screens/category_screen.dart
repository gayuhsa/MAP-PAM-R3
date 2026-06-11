import 'package:flutter/material.dart';
import '../components/category_card.dart';
import '../components/confirmation_dialog.dart';
import '../components/modal.dart';
import '../components/skeleton.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../theme.dart';

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
        final shouldSave = await showConfirmationDialog(
          // ignore: use_build_context_synchronously
          context,
          title: 'Konfirmasi Edit',
          message: 'Yakin ingin menyimpan perubahan kategori ini?',
          confirmLabel: 'Simpan',
        );
        if (!shouldSave) return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Peringatan: sedang memproses kategori...'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      if (isEditing) {
        category.name = name;
        try {
          await _categoryService.update(category);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kategori berhasil diubah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengubah kategori!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        try {
          await _categoryService.create(Category(name: name));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kategori berhasil ditambah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menambah kategori!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteCategory(String id) async {
    final option = await showDeleteChoiceDialog(
      context,
      title: 'Hapus Kategori',
      message:
          'Pilih cara menangani transaksi yang terkait dengan kategori ini.',
    );
    if (option == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Peringatan: sedang memproses penghapusan kategori...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    try {
      await _categoryService.deleteWithTransactionHandling(
        id,
        deleteTransactions: option == 'delete_all',
        reassignTransactionsToDefault: option == 'reassign',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus kategori!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _createActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.card,
      foregroundColor: AppTheme.text,
      onPressed: () => _showCategoryModal(),
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      title: 'Kategori',
      actionButton: _createActionButton(),
      content: StreamBuilder<List<Category>>(
        stream: _categoryService.getAllByUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error. Coba lagi nanti.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada kategori.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = docs[index];

              return CategoryCard(
                category: doc,
                modalCallback: _showCategoryModal,
                deleteCallback: _deleteCategory,
              );
            },
          );
        },
      ),
    );
  }
}
