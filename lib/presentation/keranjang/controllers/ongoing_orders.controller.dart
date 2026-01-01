import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';

class OngoingOrdersController extends GetxController {
  final orders = <OrderModel>[].obs;
  final loading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final page = 1.obs;
  final int perPage = 20;
  final scrollController = ScrollController();

  late final OrderService orderService;
  StreamSubscription<String>? _streamSub;
  HttpClient? _client;
  Timer? _reconnectTimer;
  Timer? _refreshDebounce;
  Timer? _pollTimer;
  int _attempts = 0;
  bool _sseHealthy = false;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    fetchOngoingOrders();
    _startSse();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchOngoingOrders(loadMore: true);
      }
    });
  }

  Future<void> fetchOngoingOrders({
    bool silent = false,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else if (!silent) {
      loading.value = true;
      errorMessage.value = '';
    }

    if (!loadMore) {
      page.value = 1;
      hasMore.value = true;
    }
    final currentPage = loadMore ? page.value + 1 : 1;

    List<OrderModel> parsed = [];
    var rawCount = 0;

    void applyOrders(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = data is Map<String, dynamic>
          ? (data['data'] as List?) ?? []
          : (data is List ? data : <dynamic>[]);
      rawCount = listData.length;
      final todayStart = DateTime.now();
      final today = DateTime(todayStart.year, todayStart.month, todayStart.day);
      bool isNotPastDate(OrderModel order) {
        final orderDate = order.updatedAt ?? order.createdAt;
        if (orderDate == null) return true;
        return !orderDate.toLocal().isBefore(today);
      }

      parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .where((order) =>
              (order.status == 'pending' || order.status == 'processing') &&
              isNotPastDate(order))
          .toList();
      errorMessage.value = '';

      if (loadMore) {
        orders.addAll(parsed);
      } else {
        orders.assignAll(parsed);
      }
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
            fallback: 'Gagal memuat order berjalan.',
          );
          orders.clear();
        }
      },
      (r) => applyOrders(r.data),
    );

    if (rawCount > 0) {
      page.value = currentPage;
    }
    hasMore.value = rawCount == perPage;

    final sorted = List<OrderModel>.from(orders);
    sorted.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
      return bDate.compareTo(aDate);
    });

    orders.assignAll(sorted);
    if (loadMore) {
      isLoadingMore.value = false;
    } else if (!silent) {
      loading.value = false;
    }
  }

  Future<void> _startSse() async {
    await _streamSub?.cancel();
    _streamSub = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.close(force: true);
    _client = HttpClient();

    final token = await SecureStorageHelper.getAccessToken() ?? '';
    if (token.isEmpty) {
      _markSseDisconnected();
      debugPrint('[OngoingOrders] SSE skipped: empty token');
      return;
    }

    final uri = Uri.parse(
      '${SecureStorageHelper.generateBaseUrl()}/api/v1/orders/events',
    );
    debugPrint('[OngoingOrders] SSE connect => $uri');

    try {
      final request = await _client!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');

      final response = await request.close();
      if (response.statusCode != 200) {
        debugPrint(
          '[OngoingOrders] SSE failed with status ${response.statusCode} '
          '(${response.reasonPhrase})',
        );
        _markSseDisconnected();
        _scheduleReconnect();
        return;
      }

      _attempts = 0;
      _markSseConnected();
      debugPrint('[OngoingOrders] SSE connected');
      _streamSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data:')) return;
              final payload = line.replaceFirst('data:', '').trim();
              if (payload.isEmpty || payload == 'ping') return;
              _refreshDebounce?.cancel();
              _refreshDebounce = Timer(
                const Duration(milliseconds: 400),
                () => fetchOngoingOrders(silent: true),
              );
            },
            onError: (error) {
              debugPrint('[OngoingOrders] SSE error: $error');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            onDone: () {
              debugPrint('[OngoingOrders] SSE connection closed');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            cancelOnError: true,
          );
    } catch (_) {
      debugPrint('[OngoingOrders] SSE connection failed');
      _markSseDisconnected();
      _scheduleReconnect();
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

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    debugPrint('[OngoingOrders] SSE reconnect scheduled');
    _attempts = (_attempts + 1).clamp(1, 6);
    final backoff = 2 << (_attempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _startSse();
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchOngoingOrders(silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void onClose() {
    _refreshDebounce?.cancel();
    _streamSub?.cancel();
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    _client?.close(force: true);
    scrollController.dispose();
    super.onClose();
  }
}
