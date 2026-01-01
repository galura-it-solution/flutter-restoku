import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/user.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/orders_events.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/user.service.dart';

class KitchenController extends GetxController {
  final orders = <OrderModel>[].obs;
  final loading = false.obs;
  final filterStatus = 'all'.obs;
  final errorMessage = ''.obs;
  final kitchenUsers = <UserModel>[].obs;
  final kitchenUsersLoading = false.obs;
  final kitchenUsersError = ''.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final page = 1.obs;
  final int perPage = 20;
  final scrollController = ScrollController();
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final bulkUpdating = false.obs;
  final updatingOrderIds = <int>{}.obs;
  final assigningOrderIds = <int>{}.obs;
  Timer? _pollTimer;
  Timer? _searchDebounce;
  Timer? _pollDebounce;
  Timer? _loadingTimeout;
  bool _hasLoadedOnce = false;
  StreamSubscription<String>? _ordersEventsSub;
  StreamSubscription<bool>? _ordersConnectionSub;
  DateTime? _lastSseRefresh;
  String? _lastPollUpdatedAt;
  bool _sseHealthy = false;

  late final OrderService orderService;
  late final UserService userService;
  late final OrdersEventsService ordersEventsService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    userService = UserService(baseUrl: baseUrl);
    ordersEventsService = Get.isRegistered<OrdersEventsService>()
        ? Get.find<OrdersEventsService>()
        : Get.put(OrdersEventsService(), permanent: true);
    fetchOrders();
    fetchKitchenUsers();
    _ordersConnectionSub =
        ordersEventsService.connectionChanges.listen((connected) {
      if (connected) {
        _markSseConnected();
      } else {
        _markSseDisconnected();
      }
    });
    _ordersEventsSub = ordersEventsService.events.listen((payload) {
      if (payload == 'ping') return;
      final now = DateTime.now();
      if (_lastSseRefresh != null &&
          now.difference(_lastSseRefresh!) < const Duration(seconds: 1)) {
        return;
      }
      _lastSseRefresh = now;
      fetchOrders();
    });
    ordersEventsService.ensureConnected();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchOrders(loadMore: true);
      }
    });
  }

  Future<void> fetchOrders({bool loadMore = false}) async {
    if (_pollDebounce?.isActive ?? false) {
      return;
    }
    _pollDebounce = Timer(const Duration(milliseconds: 800), () {});
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else if (!_hasLoadedOnce) {
      loading.value = true;
      _loadingTimeout?.cancel();
      _loadingTimeout = Timer(const Duration(seconds: 10), () {
        if (!_hasLoadedOnce && loading.value) {
          loading.value = false;
          errorMessage.value = 'Koneksi lambat. Coba refresh.';
        }
      });
    }

    if (!loadMore) {
      page.value = 1;
      hasMore.value = true;
    }
    final currentPage = loadMore ? page.value + 1 : 1;
    List<OrderModel> parsed = [];

    void applyOrders(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
      if (loadMore) {
        orders.addAll(parsed);
      } else {
        orders.assignAll(parsed);
      }
      errorMessage.value = '';
      _sortOrders();
      _refreshLastPollFromOrders(orders);
      loading.value = false;
      _hasLoadedOnce = true;
      _loadingTimeout?.cancel();
    }

    final result = await orderService.getOrders(
      page: currentPage,
      perPage: perPage,
      forceRefresh: true,
      useCache: false,
      onUpdate: applyOrders,
    );

    result.fold(
      (l) {
        errorMessage.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat order dapur.',
        );
        if (!_hasLoadedOnce) {
          loading.value = false;
        }
        _loadingTimeout?.cancel();
        _pollDebounce?.cancel();
      },
      (r) {
        applyOrders(r.data);
        _pollDebounce?.cancel();
      },
    );

    if (parsed.isNotEmpty) {
      page.value = currentPage;
    }
    hasMore.value = parsed.length == perPage;

    if (loadMore) {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchKitchenUsers() async {
    kitchenUsersLoading.value = true;
    kitchenUsersError.value = '';

    void applyUsers(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      final parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
      kitchenUsers.assignAll(parsed);
      kitchenUsersLoading.value = false;
    }

    final result = await userService.getUsers(
      role: 'kitchen',
      onUpdate: applyUsers,
    );

    result.fold(
      (l) {
        kitchenUsersError.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat user kitchen.',
        );
        kitchenUsersLoading.value = false;
      },
      (r) => applyUsers(r.data),
    );
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  void updateSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = value.trim();
    });
  }

  Future<void> updateStatus(OrderModel order, String nextStatus) async {
    if (updatingOrderIds.contains(order.id)) return;
    updatingOrderIds.add(order.id);
    try {
      final result = await orderService.updateOrderStatus(
        orderId: order.id,
        status: nextStatus,
      );

      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa update status order.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
          );
        },
        (r) {
          fetchOrders();
        },
      );
    } finally {
      updatingOrderIds.remove(order.id);
    }
  }

  Future<void> bulkUpdateStatus(String nextStatus) async {
    if (bulkUpdating.value) return;
    bulkUpdating.value = true;
    final targets = List<OrderModel>.from(filteredTodayOrders);

    for (final order in targets) {
      final result = await orderService.updateOrderStatus(
        orderId: order.id,
        status: nextStatus,
      );
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Gagal update beberapa order.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
          );
        },
        (r) {},
      );
    }

    bulkUpdating.value = false;
    fetchOrders();
  }

  Future<void> assignOrder(OrderModel order, int assignedToUserId) async {
    if (assigningOrderIds.contains(order.id)) return;
    assigningOrderIds.add(order.id);
    try {
      final result = await orderService.assignOrder(
        orderId: order.id,
        assignedToUserId: assignedToUserId,
      );

      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa assign order.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
          );
        },
        (r) {
          fetchOrders();
        },
      );
    } finally {
      assigningOrderIds.remove(order.id);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollForUpdates();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _markSseConnected() {
    if (_sseHealthy) return;
    _sseHealthy = true;
    _stopPolling();
  }

  void _markSseDisconnected() {
    if (!_sseHealthy) {
      _startPolling();
      return;
    }
    _sseHealthy = false;
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _searchDebounce?.cancel();
    _pollDebounce?.cancel();
    _loadingTimeout?.cancel();
    _ordersEventsSub?.cancel();
    _ordersConnectionSub?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _sortOrders() {
    orders.sort((a, b) {
      int statusRank(String status) {
        final normalized = status.toLowerCase();
        if (normalized == 'pending') return 0;
        if (normalized == 'processing') return 1;
        if (normalized == 'done') return 2;
        return 3;
      }

      final statusCompare = statusRank(a.status).compareTo(statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      final aTime = a.createdAt ?? DateTime(0);
      final bTime = b.createdAt ?? DateTime(0);
      final compareTime = aTime.compareTo(bTime);
      if (compareTime != 0) return compareTime;
      return a.id.compareTo(b.id);
    });
  }

  String _currentUpdatedAfter() {
    if (_lastPollUpdatedAt != null) {
      return _lastPollUpdatedAt!;
    }
    return DateTime.now()
        .toUtc()
        .subtract(const Duration(seconds: 1))
        .toIso8601String();
  }

  void _refreshLastPollFromOrders(List<OrderModel> list) {
    DateTime? latest;
    for (final item in list) {
      final candidate = item.updatedAt ?? item.createdAt;
      if (candidate == null) continue;
      if (latest == null || candidate.isAfter(latest)) {
        latest = candidate;
      }
    }
    if (latest != null) {
      _lastPollUpdatedAt = latest.toUtc().toIso8601String();
    }
  }

  void _refreshLastPollFromPayload(List<dynamic> listData) {
    DateTime? latest;
    for (final item in listData) {
      if (item is! Map<String, dynamic>) continue;
      final raw = item['updated_at']?.toString();
      if (raw == null) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) continue;
      if (latest == null || parsed.isAfter(latest)) {
        latest = parsed;
      }
    }
    if (latest != null) {
      _lastPollUpdatedAt = latest.toUtc().toIso8601String();
    }
  }

  Future<void> _pollForUpdates() async {
    void applyPoll(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      if (listData.isEmpty) return;
      _refreshLastPollFromPayload(listData);
      fetchOrders();
    }

    final result = await orderService.pollOrders(
      perPage: 50,
      updatedAfter: _currentUpdatedAfter(),
      onUpdate: applyPoll,
    );

    result.fold((l) {}, (r) => applyPoll(r.data));
  }

  List<OrderModel> get todayOrders {
    return orders.where(_isToday).toList();
  }

  List<OrderModel> get filteredTodayOrders {
    final status = filterStatus.value.toLowerCase();
    return todayOrders.where((order) {
      if (status != 'all' && order.status.toLowerCase() != status) {
        return false;
      }
      return _matchesSearch(order);
    }).toList();
  }

  List<OrderModel> get filteredHistoryOrders {
    return orders.where(_matchesSearch).toList();
  }

  int get totalTodayOrders => todayOrders.length;
  int get totalPendingToday =>
      todayOrders
          .where((order) => order.status.toLowerCase() == 'pending')
          .length;
  int get totalProcessingToday =>
      todayOrders
          .where((order) => order.status.toLowerCase() == 'processing')
          .length;
  int get totalDoneToday =>
      todayOrders.where((order) => order.status.toLowerCase() == 'done').length;

  OrderModel? getNextOrderForStatus(String status) {
    final normalized = status.toLowerCase();
    final candidates = todayOrders
        .where((order) => order.status.toLowerCase() == normalized)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(0);
      final bTime = b.createdAt ?? DateTime(0);
      final compareTime = aTime.compareTo(bTime);
      if (compareTime != 0) return compareTime;
      return a.id.compareTo(b.id);
    });
    return candidates.first;
  }

  bool canProcessOrder(OrderModel order) {
    if (order.status.toLowerCase() == 'pending') {
      return getNextOrderForStatus('pending')?.id == order.id;
    }
    if (order.status.toLowerCase() == 'processing') {
      return getNextOrderForStatus('processing')?.id == order.id;
    }
    return false;
  }

  bool _isToday(OrderModel order) {
    final createdAt = order.createdAt;
    if (createdAt == null) return false;
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool _matchesSearch(OrderModel order) {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return true;
    final idMatch = order.id.toString().contains(query);
    final tableName = order.table?.name.toLowerCase() ?? '';
    final assigned = order.assignedTo?.toLowerCase() ?? '';
    return idMatch || tableName.contains(query) || assigned.contains(query);
  }
}
