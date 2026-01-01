import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/presentation/keranjang/controllers/keranjang.controller.dart';
import 'package:slims/presentation/keranjang/controllers/ongoing_orders.controller.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/table.model.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class KeranjangScreen extends GetView<KeranjangController> {
  const KeranjangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingController = Get.find<OngoingOrdersController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MasterColor.dark_10,
        appBar: AppBar(
          backgroundColor: MasterColor.white,
          elevation: 0,
          toolbarHeight: 0,
          titleSpacing: 0,
          title: null,
          bottom: const TabBar(
            labelColor: MasterColor.primary,
            unselectedLabelColor: MasterColor.dark_50,
            indicatorColor: MasterColor.primary,
            tabs: [
              Tab(text: 'Buat Pesanan'),
              Tab(text: 'Pesanan Berjalan'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/food_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MasterColor.white.withValues(alpha: 0.85),
                      MasterColor.white.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            TabBarView(
              children: [
                _buildCreateOrderTab(context),
                _buildOngoingOrdersTab(ongoingController),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCreateOrderTab(BuildContext context) {
  final controller = Get.find<KeranjangController>();
  return Obx(() {
    if (controller.loading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: controller.listCart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/images/food_icon.png',
                        height: 64,
                        width: 64,
                      ),
                      const SizedBox(height: 12),
                      const Text('Belum ada menu di pesanan.'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.listCart.length,
                  itemBuilder: (context, index) {
                    final item = controller.listCart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: MasterColor.dark_10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  item.menu.imageUrl != null &&
                                      item.menu.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      item.menu.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.restaurant_menu,
                                                size: 28,
                                                color: MasterColor.dark_40,
                                              ),
                                            );
                                          },
                                    )
                                  : Center(
                                      child: Image.asset(
                                        'lib/assets/images/food_icon.png',
                                        height: 32,
                                        width: 32,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menu.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${formatIdr(item.menu.price)}',
                                  style: const TextStyle(
                                    color: MasterColor.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      onTap: () => controller.updateQuantity(
                                        item.menu,
                                        item.quantity - 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        item.quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _QtyButton(
                                      icon: Icons.add,
                                      onTap: () => controller.updateQuantity(
                                        item.menu,
                                        item.quantity + 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  initialValue: item.note ?? '',
                                  onChanged: (value) => controller
                                      .updateItemNote(item.menu, value),
                                  decoration: InputDecoration(
                                    hintText: 'Catatan menu (opsional)',
                                    filled: true,
                                    fillColor: MasterColor.dark_10,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                controller.removeFromCart(item.menu.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: MasterColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Meja',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: MasterColor.dark,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => TextButton.icon(
                    onPressed: controller.tableLoading.value
                        ? null
                        : () async {
                            final result = await Get.toNamed(Routes.TABLE_SCAN);
                            if (result is int) {
                              TableModel? table;
                              for (final item in controller.tables) {
                                if (item.id == result) {
                                  table = item;
                                  break;
                                }
                              }
                              if (table != null) {
                                controller.setSelectedTable(result);
                              } else {
                                Get.snackbar(
                                  'Info',
                                  'Meja tidak ditemukan.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: MasterColor.warning,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(10),
                                  borderRadius: 8,
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR'),
                  ),
                ),
              ),
              Obx(() {
                if (!controller.tableLoading.value) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: const [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Memuat daftar meja...',
                      style: TextStyle(color: MasterColor.dark_50),
                    ),
                  ],
                );
              }),
              Obx(
                () => DropdownButtonFormField<int>(
                  key: ValueKey(controller.selectedTableId.value),
                  initialValue: controller.selectedTableId.value,
                  items: controller.tables
                      .map(
                        (table) => DropdownMenuItem(
                          value: table.id,
                          child: Text(
                            '${table.name} (${table.status})',
                            style: TextStyle(
                              color: table.status == 'available'
                                  ? MasterColor.dark
                                  : MasterColor.dark_40,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.tableLoading.value
                      ? null
                      : (value) {
                          controller.selectedTableId.value = value;
                        },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MasterColor.dark_10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                onChanged: (value) => controller.orderNote.value = value,
                decoration: InputDecoration(
                  hintText: 'Catatan untuk pesanan (opsional)',
                  filled: true,
                  fillColor: MasterColor.dark_10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Obx(
                    () => Text(
                      'Rp ${formatIdr(controller.totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: MasterColor.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.submitting.value
                      ? null
                      : controller.placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MasterColor.primary,
                    foregroundColor: MasterColor.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Obx(
                    () => controller.submitting.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MasterColor.white,
                            ),
                          )
                        : const Text('Kirim Order'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });
}

Widget _buildOngoingOrdersTab(OngoingOrdersController controller) {
  return Obx(() {
    return AsyncStateView(
        loading: controller.loading.value,
        errorMessage: controller.errorMessage.value,
        isEmpty: controller.orders.isEmpty,
        emptyMessage: 'Belum ada pesanan berjalan.',
      onRetry: controller.fetchOngoingOrders,
      onRefresh: () => controller.fetchOngoingOrders(),
      child: ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.orders.length +
            (controller.isLoadingMore.value ? 2 : 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container();
          }
          if (index > controller.orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final order = controller.orders[index - 1];
          return GestureDetector(
            onTap: () => Get.toNamed(Routes.ORDER_DETAIL, arguments: order.id),
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (order.table != null) Text('Meja: ${order.table!.name}'),
                  const SizedBox(height: 6),
                  Text(
                    'Total: Rp ${formatIdr(order.totalPrice)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MasterColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  });
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    String label = status;
    Color background = MasterColor.dark_10;
    Color textColor = MasterColor.dark_50;

    if (normalized == 'pending') {
      label = 'Pending';
      background = MasterColor.warning_10;
      textColor = MasterColor.warning;
    } else if (normalized == 'processing') {
      label = 'On Progress';
      background = MasterColor.primary_10;
      textColor = MasterColor.primary;
    } else if (normalized == 'done') {
      label = 'Selesai';
      background = MasterColor.success_10;
      textColor = MasterColor.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: MasterColor.dark_10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: MasterColor.dark_60),
      ),
    );
  }
}
