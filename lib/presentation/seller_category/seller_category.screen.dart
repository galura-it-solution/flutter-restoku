import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/modal_dialog.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/seller_category/controllers/seller_category.controller.dart';

class SellerCategoryScreen extends StatelessWidget {
  const SellerCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerCategoryController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: MasterColor.white,
        elevation: 0,
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(
            color: MasterColor.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchCategories,
            icon: const Icon(Icons.refresh, color: MasterColor.dark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MasterColor.primary,
        onPressed: () => _showCategoryForm(context, controller),
        child: const Icon(Icons.add, color: MasterColor.white),
      ),
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg.jpg',
        overlayDark: 0.08,
        overlayLight: 0.92,
        child: Obx(
          () {
            return AsyncStateView(
              loading: controller.loading.value,
              errorMessage: controller.errorMessage.value,
              isEmpty: controller.categories.isEmpty,
              emptyMessage: 'Belum ada kategori.',
              onRetry: controller.fetchCategories,
              onRefresh: () => controller.fetchCategories(),
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.categories.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.categories.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final category = controller.categories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                    color: MasterColor.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: MasterColor.dark_10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: category.imageUrl != null &&
                                  category.imageUrl!.isNotEmpty
                              ? Image.network(
                                  category.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.category,
                                      color: MasterColor.dark_30,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.category,
                                  color: MasterColor.dark_30,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description ?? '- ',
                              style: const TextStyle(
                                color: MasterColor.dark_40,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showCategoryForm(
                          context,
                          controller,
                          categoryId: category.id,
                          initialName: category.name,
                          initialDescription: category.description,
                          initialImageUrl: category.imageUrl,
                        ),
                        icon: const Icon(Icons.edit, color: MasterColor.primary),
                      ),
                      Obx(() {
                        final isDeleting =
                            controller.deletingId.value == category.id;
                        return IconButton(
                          onPressed: isDeleting
                              ? null
                              : () => controller.deleteCategory(category.id),
                          icon: isDeleting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MasterColor.danger,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete,
                                  color: MasterColor.danger,
                                ),
                        );
                      }),
                    ],
                  ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCategoryForm(
    BuildContext context,
    SellerCategoryController controller, {
    int? categoryId,
    String? initialName,
    String? initialDescription,
    String? initialImageUrl,
  }) {
    final nameController = TextEditingController(text: initialName ?? '');
    final descController = TextEditingController(text: initialDescription ?? '');
    final imageController = TextEditingController(text: initialImageUrl ?? '');
    final imagePath = ValueNotifier<String?>(null);
    final imagePicker = ImagePicker();

    Future<void> pickImage() async {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      imagePath.value = picked.path;
    }

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: MasterColor.dark_10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MasterColor.primary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => FormDialogShell(
        icon: Icons.category,
        title: categoryId == null ? 'Tambah Kategori' : 'Edit Kategori',
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: inputDecoration.copyWith(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: inputDecoration.copyWith(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                readOnly: true,
                decoration: inputDecoration.copyWith(
                  labelText: 'Image URL (otomatis)',
                  hintText: 'Akan terisi setelah upload',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Gambar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: imagePath,
                    builder: (context, path, _) {
                      return IconButton(
                        onPressed: path == null
                            ? null
                            : () => imagePath.value = null,
                        icon: const Icon(Icons.delete_outline),
                        color: MasterColor.danger,
                        tooltip: 'Hapus gambar',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: imagePath,
                builder: (context, path, _) {
                  if (path == null || path.isEmpty) {
                    final url = imageController.text.trim();
                    if (url.isEmpty) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: MasterColor.dark_10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Pratinjau gambar',
                            style: TextStyle(color: MasterColor.dark_40),
                          ),
                        ),
                      );
                    }

                    return Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MasterColor.dark_10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: MasterColor.dark_30,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MasterColor.dark_10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: MasterColor.dark_30,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  onPressed: controller.actionLoading.value
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final isLoading = controller.actionLoading.value;
                return ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final payload = {
                            'name': nameController.text.trim(),
                            'description': descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                          };

                          if (categoryId == null) {
                            await controller.createCategory(
                              payload,
                              imagePath: imagePath.value,
                            );
                          } else {
                            await controller.updateCategory(
                              categoryId,
                              payload,
                              imagePath: imagePath.value,
                            );
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MasterColor.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isLoading ? 'Menyimpan...' : 'Simpan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        imagePath.dispose();
        nameController.dispose();
        descController.dispose();
        imageController.dispose();
      });
    });
  }
}
