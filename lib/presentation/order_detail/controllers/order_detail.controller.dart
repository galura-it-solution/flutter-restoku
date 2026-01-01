import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/orders_events.service.dart';

class OrderDetailController extends GetxController {
  final order = Rxn<OrderModel>();
  final loading = false.obs;
  final errorMessage = ''.obs;

  late final OrderService orderService;
  StreamSubscription<String>? _ordersEventsSub;
  StreamSubscription<bool>? _ordersConnectionSub;
  Timer? _pollTimer;
  String? _lastPollUpdatedAt;
  bool _sseHealthy = false;
  late final OrdersEventsService ordersEventsService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);

    final orderId = Get.arguments as int?;
    if (orderId != null) {
      fetchOrder(orderId);
      ordersEventsService = Get.isRegistered<OrdersEventsService>()
          ? Get.find<OrdersEventsService>()
          : Get.put(OrdersEventsService(), permanent: true);
      _ordersConnectionSub =
          ordersEventsService.connectionChanges.listen((connected) {
        if (connected) {
          _markSseConnected();
        } else {
          _markSseDisconnected(orderId);
        }
      });
      _ordersEventsSub = ordersEventsService.events.listen((payload) {
        if (payload == 'ping') return;
        try {
          final data = json.decode(payload) as Map<String, dynamic>;
          final eventId = data['id'] as int?;
          if (eventId == orderId) {
            fetchOrder(orderId, silent: true);
          }
        } catch (_) {}
      });
      ordersEventsService.ensureConnected();
    }
  }

  Future<void> fetchOrder(int orderId, {bool silent = false}) async {
    if (!silent) {
      loading.value = true;
    }
    void applyOrder(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        order.value = OrderModel.fromJson(payload);
        errorMessage.value = '';
        final updatedAt = order.value?.updatedAt;
        if (updatedAt != null) {
          _lastPollUpdatedAt = updatedAt.toUtc().toIso8601String();
        }
        if (!silent) {
          loading.value = false;
        }
      }
    }

    final result = await orderService.getOrderDetail(
      orderId,
      forceRefresh: true,
      useCache: false,
      onUpdate: applyOrder,
    );

    result.fold(
      (l) {
        if (!silent) {
          errorMessage.value = ApiErrorMessage.from(
            l,
            fallback: 'Gagal memuat detail order.',
          );
          loading.value = false;
        }
      },
      (r) => applyOrder(r.data),
    );
  }

  void _markSseConnected() {
    if (_sseHealthy) return;
    _sseHealthy = true;
    _stopPolling();
  }

  void _markSseDisconnected(int orderId) {
    if (!_sseHealthy) {
      _startPolling(orderId);
      return;
    }
    _sseHealthy = false;
    _startPolling(orderId);
  }

  void _startPolling(int orderId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _pollForUpdates(orderId);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void onClose() {
    _ordersEventsSub?.cancel();
    _ordersConnectionSub?.cancel();
    _pollTimer?.cancel();
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

  Future<void> _pollForUpdates(int orderId) async {
    void applyPoll(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      if (listData.isEmpty) return;
      _refreshLastPollFromPayload(listData);
      for (final item in listData) {
        if (item is Map<String, dynamic> && item['id'] == orderId) {
          fetchOrder(orderId, silent: true);
          break;
        }
      }
    }

    final result = await orderService.pollOrders(
      perPage: 50,
      updatedAfter: _currentUpdatedAfter(),
      onUpdate: applyPoll,
    );

    result.fold((l) {}, (r) => applyPoll(r.data));
  }
}
