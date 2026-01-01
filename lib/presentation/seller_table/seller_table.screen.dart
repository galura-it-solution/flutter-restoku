import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/modal_dialog.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/table.model.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/seller_table/controllers/seller_table.controller.dart';

class SellerTableScreen extends StatelessWidget {
  const SellerTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerTableController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: MasterColor.white,
        elevation: 0,
        title: const Text(
          'Kelola Meja',
          style: TextStyle(
            color: MasterColor.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchTables,
            icon: const Icon(Icons.refresh, color: MasterColor.dark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MasterColor.primary,
        onPressed: () => _showTableForm(context, controller),
        child: const Icon(Icons.add, color: MasterColor.white),
      ),
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_4.jpg',
        overlayDark: 0.08,
        overlayLight: 0.92,
        child: Obx(
          () {
            return AsyncStateView(
              loading: controller.loading.value,
              errorMessage: controller.errorMessage.value,
              isEmpty: controller.tables.isEmpty,
              emptyMessage: 'Belum ada meja.',
              onRetry: controller.fetchTables,
              onRefresh: () => controller.fetchTables(),
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.tables.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.tables.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final table = controller.tables[index];
                  final isOccupied = table.status == 'occupied';
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                table.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                table.status,
                                style: TextStyle(
                                  color: table.status == 'occupied'
                                      ? MasterColor.warning
                                      : MasterColor.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showTableForm(
                            context,
                            controller,
                            table: table,
                          ),
                          icon: const Icon(
                            Icons.edit,
                            color: MasterColor.primary,
                          ),
                        ),
                        Obx(() {
                          final isDeleting =
                              controller.deletingId.value == table.id;
                          return Tooltip(
                            message: isOccupied
                                ? 'Tidak bisa hapus meja yang sedang terisi.'
                                : 'Hapus meja',
                            child: IconButton(
                              onPressed: isOccupied || isDeleting
                                  ? null
                                  : () => controller.deleteTable(table.id),
                              icon: isDeleting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: MasterColor.danger,
                                      ),
                                    )
                                  : Icon(
                                      Icons.delete,
                                      color: isOccupied
                                          ? MasterColor.dark_20
                                          : MasterColor.danger,
                                    ),
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

  void _showTableForm(
    BuildContext context,
    SellerTableController controller, {
    TableModel? table,
  }) {
    final nameController = TextEditingController(text: table?.name ?? '');
    final status = (table?.status ?? 'available').obs;

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
        icon: Icons.table_bar,
        title: table == null ? 'Tambah Meja' : 'Edit Meja',
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: inputDecoration.copyWith(labelText: 'Nama Meja'),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  key: ValueKey(status.value),
                  initialValue: status.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('available'),
                    ),
                    DropdownMenuItem(
                      value: 'occupied',
                      child: Text('occupied'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      status.value = value;
                    }
                  },
                  decoration: inputDecoration.copyWith(labelText: 'Status'),
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
                            'status': status.value,
                          };

                          if (table == null) {
                            await controller.createTable(payload);
                          } else {
                            await controller.updateTable(table.id, payload);
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
        nameController.dispose();
      });
    });
  }
}
