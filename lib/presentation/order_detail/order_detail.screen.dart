import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/order_detail/controllers/order_detail.controller.dart';

class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: MasterColor.white,
        elevation: 0,
        title: const Text(
          'Detail Order',
          style: TextStyle(
            color: MasterColor.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_3.jpg',
        overlayDark: 0.08,
        overlayLight: 0.92,
        child: Obx(
          () {
            final order = controller.order.value;
            return AsyncStateView(
              loading: controller.loading.value,
              errorMessage: controller.errorMessage.value,
              isEmpty: order == null,
              emptyMessage: 'Order tidak ditemukan.',
              onRetry: () {
                final orderId = Get.arguments as int?;
                if (orderId != null) {
                  controller.fetchOrder(orderId);
                }
              },
              onRefresh: () async {
                final orderId = Get.arguments as int?;
                if (orderId != null) {
                  await controller.fetchOrder(orderId);
                }
              },
              child: order == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (order.table != null)
                        Text('Meja: ${order.table!.name}'),
                      const SizedBox(height: 6),
                      Text(
                        'Status: ${_orderStatusLabel(order.status)}',
                        style: const TextStyle(
                          color: MasterColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _QueueInfoCard(
                              label: 'Antrian kamu',
                              value: order.queueNumber?.toString() ?? '-',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QueueInfoCard(
                              label: 'Sedang diproses',
                              value: order.currentProcessingQueueNumber
                                      ?.toString() ??
                                  '-',
                            ),
                          ),
                        ],
                      ),
                      if ((order.assignedTo ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Assigned: ${order.assignedTo}',
                          style: const TextStyle(
                            color: MasterColor.dark_60,
                          ),
                        ),
                      ],
                      if ((order.note ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Catatan: ${order.note}',
                          style: const TextStyle(
                            color: MasterColor.dark_60,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusStep(
                        title: 'Pending',
                        active: order.status == 'pending' ||
                            order.status == 'processing' ||
                            order.status == 'done',
                      ),
                      _StatusLine(
                        active: order.status == 'processing' ||
                            order.status == 'done',
                      ),
                      _StatusStep(
                        title: 'Proses',
                        active: order.status == 'processing' ||
                            order.status == 'done',
                      ),
                      _StatusLine(
                        active: order.status == 'done',
                      ),
                      _StatusStep(
                        title: 'Selesai',
                        active: order.status == 'done',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menu?.name ??
                                          item.menuName ??
                                          'Menu #${item.menuId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty ${item.quantity} x Rp ${formatIdr(item.price)}',
                                      style: const TextStyle(
                                        color: MasterColor.dark_40,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if ((item.notes ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Catatan: ${item.notes}',
                                        style: const TextStyle(
                                          color: MasterColor.dark_60,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${formatIdr(item.subtotal)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: MasterColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Subtotal',
                        value: order.subtotal,
                      ),
                      const SizedBox(height: 8),
                      _PriceRow(
                        label: 'Service charge',
                        value: order.serviceCharge,
                      ),
                      const SizedBox(height: 8),
                      _PriceRow(
                        label: 'Pajak',
                        value: order.tax,
                      ),
                      const Divider(height: 24),
                      _PriceRow(
                        label: 'Total',
                        value: order.totalPrice,
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _QueueInfoCard extends StatelessWidget {
  const _QueueInfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MasterColor.dark_10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MasterColor.dark_30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MasterColor.dark_60,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: MasterColor.dark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final num value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
      color: highlight ? MasterColor.primary : MasterColor.dark,
      fontSize: highlight ? 16 : 14,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('Rp ${formatIdr(value)}', style: style),
      ],
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({required this.title, required this.active});

  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? MasterColor.primary : MasterColor.dark_30;
    return Column(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? MasterColor.primary : MasterColor.dark_20,
      ),
    );
  }
}

String _orderStatusLabel(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'pending') {
    return 'Pending';
  }
  if (normalized == 'processing') {
    return 'On Progress';
  }
  if (normalized == 'done') {
    return 'Selesai';
  }
  return status;
}
