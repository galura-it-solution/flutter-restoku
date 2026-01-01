import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';

class OrderDetailController extends GetxController {
  final order = Rxn<OrderModel>();
  final loading = false.obs;
  final errorMessage = ''.obs;

  late final OrderService orderService;
  StreamSubscription<String>? _streamSub;
  HttpClient? _client;
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  int _attempts = 0;
  bool _sseHealthy = false;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);

    final orderId = Get.arguments as int?;
    if (orderId != null) {
      fetchOrder(orderId);
      _startSse(orderId);
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

  Future<void> _startSse(int orderId) async {
    await _streamSub?.cancel();
    _streamSub = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.close(force: true);
    _client = HttpClient();

    final token = await SecureStorageHelper.getAccessToken() ?? '';
    if (token.isEmpty) {
      _markSseDisconnected(orderId);
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
          '[OrderDetail] SSE failed with status ${response.statusCode}',
        );
        _markSseDisconnected(orderId);
        _scheduleReconnect(orderId);
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
              try {
                final data = json.decode(payload) as Map<String, dynamic>;
                final eventId = data['id'] as int?;
                if (eventId == orderId) {
                  fetchOrder(orderId, silent: true);
                }
              } catch (_) {}
            },
            onError: (error) {
              debugPrint('[OrderDetail] SSE error: $error');
              _markSseDisconnected(orderId);
              _scheduleReconnect(orderId);
            },
            onDone: () {
              debugPrint('[OrderDetail] SSE connection closed');
              _markSseDisconnected(orderId);
              _scheduleReconnect(orderId);
            },
            cancelOnError: true,
          );
    } catch (_) {
      debugPrint('[OrderDetail] SSE connection failed');
      _markSseDisconnected(orderId);
      _scheduleReconnect(orderId);
    }
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

  void _scheduleReconnect(int orderId) {
    if (_reconnectTimer?.isActive ?? false) return;
    debugPrint('[OrderDetail] SSE reconnect scheduled');
    _attempts = (_attempts + 1).clamp(1, 6);
    final backoff = 2 << (_attempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _startSse(orderId);
    });
  }

  void _startPolling(int orderId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchOrder(orderId, silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void onClose() {
    _streamSub?.cancel();
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    _client?.close(force: true);
    super.onClose();
  }
}
