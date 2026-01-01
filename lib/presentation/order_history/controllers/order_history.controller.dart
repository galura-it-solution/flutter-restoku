import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';

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
    fetchOrders();
    _startSse();

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
      return;
    }

    final uri = Uri.parse(
      '${SecureStorageHelper.generateBaseUrl()}/api/v1/orders/events',
    );

    try {
      final request = await _client!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');

      final response = await request.close();
      if (response.statusCode != 200) {
        debugPrint(
          '[OrderHistory] SSE failed with status ${response.statusCode}',
        );
        _markSseDisconnected();
        _scheduleReconnect();
        return;
      }

      _attempts = 0;
      _markSseConnected();
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
                () => fetchOrders(silent: true),
              );
            },
            onError: (error) {
              debugPrint('[OrderHistory] SSE error: $error');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            onDone: () {
              debugPrint('[OrderHistory] SSE connection closed');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            cancelOnError: true,
          );
    } catch (_) {
      debugPrint('[OrderHistory] SSE connection failed');
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
    debugPrint('[OrderHistory] SSE reconnect scheduled');
    _attempts = (_attempts + 1).clamp(1, 6);
    final backoff = 2 << (_attempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _startSse();
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchOrders(silent: true);
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
