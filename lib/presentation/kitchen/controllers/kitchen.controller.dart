import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/user.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
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
  Timer? _sseReconnectTimer;
  StreamSubscription<String>? _sseSub;
  HttpClient? _sseClient;
  int _sseAttempts = 0;
  DateTime? _lastSseRefresh;
  bool _sseHealthy = false;

  late final OrderService orderService;
  late final UserService userService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    userService = UserService(baseUrl: baseUrl);
    fetchOrders();
    fetchKitchenUsers();
    _startSse();

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
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchOrders();
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

  Future<void> _startSse() async {
    await _sseSub?.cancel();
    _sseSub = null;
    _sseReconnectTimer?.cancel();
    _sseReconnectTimer = null;
    _sseClient?.close(force: true);
    _sseClient = HttpClient();

    final token = await SecureStorageHelper.getAccessToken() ?? '';
    if (token.isEmpty) {
      _markSseDisconnected();
      return;
    }

    final uri = Uri.parse(
      '${SecureStorageHelper.generateBaseUrl()}/api/v1/orders/events',
    );

    try {
      final request = await _sseClient!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');

      final response = await request.close();
      if (response.statusCode != 200) {
        debugPrint('[Kitchen] SSE failed with status ${response.statusCode}');
        _markSseDisconnected();
        _scheduleSseReconnect();
        return;
      }

      _sseAttempts = 0;
      _markSseConnected();
      _sseSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data:')) return;
              final payload = line.replaceFirst('data:', '').trim();
              if (payload.isEmpty || payload == 'ping') return;
              final now = DateTime.now();
              if (_lastSseRefresh != null &&
                  now.difference(_lastSseRefresh!) <
                      const Duration(seconds: 1)) {
                return;
              }
              _lastSseRefresh = now;
              fetchOrders();
            },
            onError: (error) {
              debugPrint('[Kitchen] SSE error: $error');
              _markSseDisconnected();
              _scheduleSseReconnect();
            },
            onDone: () {
              debugPrint('[Kitchen] SSE connection closed');
              _markSseDisconnected();
              _scheduleSseReconnect();
            },
            cancelOnError: true,
          );
    } catch (_) {
      debugPrint('[Kitchen] SSE connection failed');
      _markSseDisconnected();
      _scheduleSseReconnect();
    }
  }

  void _scheduleSseReconnect() {
    if (_sseReconnectTimer?.isActive ?? false) return;
    debugPrint('[Kitchen] SSE reconnect scheduled');
    _sseAttempts = (_sseAttempts + 1).clamp(1, 6);
    final backoff = 2 << (_sseAttempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;

    _sseReconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      await _startSse();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _searchDebounce?.cancel();
    _pollDebounce?.cancel();
    _loadingTimeout?.cancel();
    _sseReconnectTimer?.cancel();
    _sseSub?.cancel();
    _sseClient?.close(force: true);
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
