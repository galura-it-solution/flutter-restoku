import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/modal_dialog.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/category.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/presentation/seller_menu/controllers/seller_menu.controller.dart';
import 'package:slims/presentation/seller_menu/widgets/menu_image_preview.dart';

class MenuFormDialog extends StatefulWidget {
  const MenuFormDialog({
    super.key,
    required this.controller,
    this.menu,
  });

  final SellerMenuController controller;
  final MenuModel? menu;

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController descController;
  late final TextEditingController imageController;
  late final TextEditingController stockController;
  late final ValueNotifier<String?> imagePath;
  late final RxBool isActive;
  late final RxInt selectedCategoryId;
  late final InputDecoration inputDecoration;

  @override
  void initState() {
    super.initState();
    final menu = widget.menu;
    nameController = TextEditingController(text: menu?.name ?? '');
    priceController = TextEditingController(text: menu?.price.toString() ?? '');
    descController = TextEditingController(text: menu?.description ?? '');
    imageController = TextEditingController(text: menu?.imageUrl ?? '');
    stockController =
        TextEditingController(text: menu?.stock?.toString() ?? '');
    imagePath = ValueNotifier<String?>(null);
    isActive = (menu?.isActive ?? true).obs;
    selectedCategoryId = (menu?.categoryId ?? 0).obs;
    inputDecoration = InputDecoration(
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
  }

  @override
  void dispose() {
    imagePath.dispose();
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    stockController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (file != null) {
      imagePath.value = file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final controller = widget.controller;

    return FormDialogShell(
      icon: Icons.restaurant_menu,
      title: menu == null ? 'Tambah Menu' : 'Edit Menu',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: inputDecoration.copyWith(labelText: 'Nama'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: inputDecoration.copyWith(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: stockController,
                    decoration:
                        inputDecoration.copyWith(labelText: 'Stok (opsional)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
                      onPressed: path == null ? null : () => imagePath.value = null,
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
                return MenuImagePreview(
                  filePath: path,
                  imageUrl: imageController.text.trim(),
                );
              },
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<int>(
                key: ValueKey(selectedCategoryId.value),
                initialValue: selectedCategoryId.value == 0
                    ? null
                    : selectedCategoryId.value,
                items: controller.categories
                    .map(
                      (CategoryModel category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategoryId.value = value;
                  }
                },
                decoration: inputDecoration.copyWith(labelText: 'Kategori'),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive.value,
                title: const Text('Aktif'),
                onChanged: (value) => isActive.value = value,
              ),
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
                          'price':
                              int.tryParse(priceController.text.trim()) ?? 0,
                          'description': descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          'stock': stockController.text.trim().isEmpty
                              ? null
                              : int.tryParse(stockController.text.trim()) ?? 0,
                          'category_id': selectedCategoryId.value == 0
                              ? null
                              : selectedCategoryId.value,
                          'is_active': isActive.value,
                        };

                        if (menu == null) {
                          await controller.createMenu(
                            payload,
                            imagePath: imagePath.value,
                          );
                        } else {
                          await controller.updateMenu(
                            menu.id,
                            payload,
                            imagePath: imagePath.value,
                          );
                        }

                        if (!context.mounted) return;
                        Navigator.of(context).pop();
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
    );
  }
}
