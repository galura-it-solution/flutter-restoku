import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/core/utils/modal_dialog.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/user.model.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
 import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/kitchen/controllers/kitchen.controller.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override  
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  late final KitchenController _controller;

  void _showAssignDialog(
    BuildContext context,
    KitchenController controller,
    OrderModel order,
  ) {
    final selectedUserNotifier = ValueNotifier<UserModel?>(null);
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
        icon: Icons.assignment_ind,
        title: 'Assign Order',
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Obx(
            () {
              if (controller.kitchenUsersLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.kitchenUsersError.value.isNotEmpty) {
                return Text(
                  controller.kitchenUsersError.value,
                  style: const TextStyle(color: MasterColor.dark_50),
                );
              }
              if (controller.kitchenUsers.isEmpty) {
                return const Text(
                  'User kitchen belum tersedia.',
                  style: TextStyle(color: MasterColor.dark_50),
                );
              }

              if (selectedUserNotifier.value == null) {
                final initialUser = controller.kitchenUsers.firstWhere(
                  (user) => user.id == order.assignedToUserId,
                  orElse: () => controller.kitchenUsers.first,
                );
                selectedUserNotifier.value = initialUser;
              }

              return ValueListenableBuilder<UserModel?>(
                valueListenable: selectedUserNotifier,
                builder: (context, selectedUser, _) {
                  return DropdownButtonFormField<UserModel>(
                    initialValue: selectedUser,
                    items: controller.kitchenUsers
                        .map(
                          (user) => DropdownMenuItem(
                            value: user,
                            child: Text(user.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      selectedUserNotifier.value = value;
                    },
                    decoration:
                        inputDecoration.copyWith(labelText: 'User kitchen'),
                  );
                },
              );
            },
          ),
        ),
        actions: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final isAssigning =
                    controller.assigningOrderIds.contains(order.id);
                return ElevatedButton.icon(
                  onPressed: isAssigning
                      ? null
                      : () async {
                          final selectedUser = selectedUserNotifier.value;
                          if (selectedUser == null) return;
                          await controller.assignOrder(order, selectedUser.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  icon: isAssigning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MasterColor.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isAssigning ? 'Menyimpan...' : 'Simpan'),
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
      selectedUserNotifier.dispose();
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.put(KitchenController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FoodBackground(
          imagePath: 'lib/assets/images/food_bg_4.jpg',
          overlayDark: 0.08,
          overlayLight: 0.92,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller.searchController,
                      onChanged: _controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari order atau nama meja...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: MasterColor.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label:
                                    'Semua (${_controller.totalTodayOrders})',
                                selected:
                                    _controller.filterStatus.value == 'all',
                                onTap: () => _controller.setFilter('all'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label:
                                    'Pending (${_controller.totalPendingToday})',
                                selected:
                                    _controller.filterStatus.value == 'pending',
                                onTap: () => _controller.setFilter('pending'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label:
                                    'Diproses (${_controller.totalProcessingToday})',
                                selected:
                                    _controller.filterStatus.value == 'processing',
                                onTap: () => _controller.setFilter('processing'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label:
                                    'Selesai (${_controller.totalDoneToday})',
                                selected:
                                    _controller.filterStatus.value == 'done',
                                onTap: () => _controller.setFilter('done'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(
                  () {
                    final orders = _controller.filteredTodayOrders;
                    return AsyncStateView(
                      loading: _controller.loading.value,
                      errorMessage: _controller.errorMessage.value,
                      isEmpty: orders.isEmpty,
                      emptyMessage: 'Belum ada order hari ini.',
                      onRetry: _controller.fetchOrders,
                      onRefresh: () => _controller.fetchOrders(),
                      childIsScrollable: true,
                      child: _OrderList(
                        orders: orders,
                        scrollController: _controller.scrollController,
                        onAssign: (order) => _showAssignDialog(
                          context,
                          _controller,
                          order,
                        ),
                        onTapOrder: (order) => Get.toNamed(
                          Routes.ORDER_DETAIL,
                          arguments: order.id,
                        ),
                        onUpdateStatus: _controller.updateStatus,
                        canProcess: _controller.canProcessOrder,
                        isUpdating: (order) => _controller.updatingOrderIds
                            .contains(order.id),
                        isAssigning: (order) =>
                            _controller.assigningOrderIds.contains(order.id),
                        isLoadingMore: _controller.isLoadingMore.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.scrollController,
    required this.onTapOrder,
    required this.onAssign,
    required this.onUpdateStatus,
    required this.canProcess,
    required this.isUpdating,
    required this.isAssigning,
    required this.isLoadingMore,
  });

  final List<OrderModel> orders;
  final ScrollController scrollController;
  final ValueChanged<OrderModel> onTapOrder;
  final ValueChanged<OrderModel> onAssign;
  final void Function(OrderModel order, String status) onUpdateStatus;
  final bool Function(OrderModel order) canProcess;
  final bool Function(OrderModel order) isUpdating;
  final bool Function(OrderModel order) isAssigning;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final order = orders[index];
        return InkWell(
          onTap: () => onTapOrder(order),
          borderRadius: BorderRadius.circular(14),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _PriorityLabel(createdAt: order.createdAt),
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
                        _statusLabel(order.status),
                        style: const TextStyle(
                          color: MasterColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.table != null) Text('Meja: ${order.table!.name}'),
                const SizedBox(height: 6),
                _ElapsedTime(createdAt: order.createdAt),
                const SizedBox(height: 8),
                Text(
                  'Total: Rp ${formatIdr(order.totalPrice)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MasterColor.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.assignedToUserId == null ||
                                (order.assignedTo ?? '').isEmpty
                            ? 'Belum di-assign'
                            : 'Assigned: ${order.assignedTo}',
                        style: const TextStyle(
                          color: MasterColor.dark_50,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Obx(() {
                      final loading = isAssigning(order);
                      return TextButton(
                        onPressed: loading ? null : () => onAssign(order),
                        child: loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Assign'),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (order.status == 'pending')
                      Expanded(
                        child: Obx(() {
                          final isLoading = isUpdating(order);
                          return ElevatedButton(
                            onPressed: canProcess(order)
                                ? (isLoading
                                    ? null
                                    : () => onUpdateStatus(
                                          order,
                                          'processing',
                                        ))
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MasterColor.warning,
                              foregroundColor: MasterColor.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: MasterColor.white,
                                    ),
                                  )
                                : Text(
                                    order.assignedToUserId == null
                                        ? 'Assign Dulu'
                                        : (canProcess(order)
                                            ? 'Proses'
                                            : 'Menunggu Giliran'),
                                  ),
                          );
                        }),
                      ),
                    if (order.status == 'processing')
                      Expanded(
                        child: Obx(() {
                          final isLoading = isUpdating(order);
                          return ElevatedButton(
                            onPressed: canProcess(order)
                                ? (isLoading
                                    ? null
                                    : () => onUpdateStatus(
                                          order,
                                          'done',
                                        ))
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MasterColor.primary,
                              foregroundColor: MasterColor.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: MasterColor.white,
                                    ),
                                  )
                                : Text(
                                    order.assignedToUserId == null
                                        ? 'Assign Dulu'
                                        : (canProcess(order)
                                            ? 'Selesai'
                                            : 'Menunggu Giliran'),
                                  ),
                          );
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? MasterColor.primary : MasterColor.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MasterColor.primary : MasterColor.dark_20,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MasterColor.white : MasterColor.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ElapsedTime extends StatelessWidget {
  const _ElapsedTime({required this.createdAt});

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    if (createdAt == null) return const SizedBox.shrink();
    final diff = DateTime.now().difference(createdAt!);
    final minutes = diff.inMinutes;
    final label = minutes < 1 ? 'Baru saja' : '$minutes menit';
    return Text(
      'Waktu: $label',
      style: const TextStyle(
        color: MasterColor.dark_50,
        fontSize: 12,
      ),
    );
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.createdAt});

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    if (createdAt == null) {
      return const SizedBox.shrink();
    }

    final minutes = DateTime.now().difference(createdAt!).inMinutes;
    String label = 'Normal';
    Color color = MasterColor.success;

    if (minutes >= 20) {
      label = 'High';
      color = MasterColor.danger;
    } else if (minutes >= 10) {
      label = 'Medium';
      color = MasterColor.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
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
