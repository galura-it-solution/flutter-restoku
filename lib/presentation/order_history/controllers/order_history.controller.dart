import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/orders_events.service.dart';

class OrderHistoryController extends GetxController {
  final orders = <OrderModel>[].obs;
  final loading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final page = 1.obs;
  final int perPage = 20;
  final scrollController = ScrollController();

  late final OrderService orderService;
  StreamSubscription<String>? _ordersEventsSub;
  StreamSubscription<bool>? _ordersConnectionSub;
  Timer? _refreshDebounce;
  Timer? _pollTimer;
  String? _lastPollUpdatedAt;
  bool _sseHealthy = false;
  late final OrdersEventsService ordersEventsService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    fetchOrders();
    ordersEventsService = Get.isRegistered<OrdersEventsService>()
        ? Get.find<OrdersEventsService>()
        : Get.put(OrdersEventsService(), permanent: true);
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
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 400),
        () => fetchOrders(silent: true),
      );
    });
    ordersEventsService.ensureConnected();
    if (!ordersEventsService.isConnected) {
      _markSseDisconnected();
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchOrders(loadMore: true);
      }
    });
  }

  Future<void> fetchOrders({bool silent = false, bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else if (!silent) {
      loading.value = true;
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
      _refreshLastPollFromOrders(parsed);

      if (loadMore) {
        orders.addAll(parsed);
      } else {
        orders.assignAll(parsed);
      }

      errorMessage.value = '';
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
        if (!silent) {
          errorMessage.value = ApiErrorMessage.from(
            l,
            fallback: 'Gagal memuat riwayat order.',
          );
          loading.value = false;
        }
      },
      (r) => applyOrders(r.data),
    );

    if (parsed.isNotEmpty) {
      page.value = currentPage;
    }
    hasMore.value = parsed.length == perPage;

    if (!silent && !loadMore) {
      loading.value = false;
    }
    if (loadMore) {
      isLoadingMore.value = false;
    }
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

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollForUpdates();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void onClose() {
    _refreshDebounce?.cancel();
    _ordersEventsSub?.cancel();
    _ordersConnectionSub?.cancel();
    _pollTimer?.cancel();
    scrollController.dispose();
    super.onClose();
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
      fetchOrders(silent: true);
    }

    final result = await orderService.pollOrders(
      perPage: 50,
      updatedAfter: _currentUpdatedAfter(),
      onUpdate: applyPoll,
    );

    result.fold((l) {}, (r) => applyPoll(r.data));
  }
}
