import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/order_history/controllers/order_history.controller.dart';

class OrderHistoryScreen extends GetView<OrderHistoryController> {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSellerFuture = SecureStorageHelper.isSeller();
    return FutureBuilder<bool>(
      future: isSellerFuture,
      builder: (context, snapshot) {
        final isSeller = snapshot.data ?? false;
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: isSeller
                ? AppBar(
                    backgroundColor: MasterColor.white,
                    elevation: 0,
                    title: const Text(
                      'Riwayat Semua Order',
                      style: TextStyle(
                        color: MasterColor.dark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                      color: MasterColor.dark,
                    ),
                  )
                : null,
            body: FoodBackground(
              imagePath: 'lib/assets/images/food_bg_4.jpg',
              overlayDark: 0.1,
              overlayLight: 0.9,
              child: Obx(
                () {
                  return AsyncStateView(
                    loading: controller.loading.value,
                    errorMessage: controller.errorMessage.value,
                    isEmpty: controller.orders.isEmpty,
                    emptyMessage: 'Belum ada order.',
                    onRetry: controller.fetchOrders,
                    onRefresh: () => controller.fetchOrders(),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.orders.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.orders.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final order = controller.orders[index];
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                            Routes.ORDER_DETAIL,
                            arguments: order.id,
                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: MasterColor.primary_10,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: const TextStyle(
                                          color: MasterColor.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (order.table != null)
                                  Text('Meja: ${order.table!.name}'),
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
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
