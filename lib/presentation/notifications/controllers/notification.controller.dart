import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/order.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class NotificationController extends GetxController {
  final _seenOrders = <int>{};
  final _seenReadyKeys = <String>{};
  final _running = false.obs;
  Timer? _pollTimer;
  Timer? _sseReconnectTimer;
  int _sseAttempts = 0;
  HttpClient? _client;
  StreamSubscription<String>? _streamSub;
  bool _sseHealthy = false;
  String? _lastPollUpdatedAt;

  late final OrderService orderService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    _start();
  }

  Future<void> _start() async {
    if (_running.value) return;
    _running.value = true;

    final token = await SecureStorageHelper.getAccessToken() ?? '';
    if (token.isEmpty) {
      _running.value = false;
      return;
    }

    _startSse(token);
  }

  void _startSse(String token) async {
    _sseReconnectTimer?.cancel();
    _sseReconnectTimer = null;
    await _streamSub?.cancel();
    _streamSub = null;
    _client?.close(force: true);
    _client = HttpClient();

    final uri = Uri.parse(
      '${SecureStorageHelper.generateBaseUrl()}/api/v1/notifications/stream',
    );

    try {
      final request = await _client!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');

      final response = await request.close();
      if (response.statusCode != 200) {
        debugPrint(
          '[Notifications] SSE failed with status ${response.statusCode}',
        );
        _markSseDisconnected();
        _scheduleReconnect();
        return;
      }

      _sseAttempts = 0;
      _markSseConnected();
      _streamSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('data:')) {
                final payload = line.replaceFirst('data:', '').trim();
                if (payload == 'ping' || payload.isEmpty) return;
                _handleEvent(payload);
              }
            },
            onError: (error) {
              debugPrint('[Notifications] SSE error: $error');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            onDone: () {
              debugPrint('[Notifications] SSE connection closed');
              _markSseDisconnected();
              _scheduleReconnect();
            },
            cancelOnError: true,
          );
    } catch (_) {
      debugPrint('[Notifications] SSE connection failed');
      _markSseDisconnected();
      _scheduleReconnect();
    }
  }

  void _markSseConnected() {
    if (_sseHealthy) return;
    _sseHealthy = true;
    _stopPollingFallback();
  }

  void _markSseDisconnected() {
    if (!_sseHealthy) {
      _startPollingFallback();
      return;
    }
    _sseHealthy = false;
    _startPollingFallback();
  }

  void _handleEvent(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      final orderId = data['order_id'] as int?;
      final notifiedAt = data['notified_at']?.toString() ?? '';
      if (orderId == null) return;

      final readyKey = notifiedAt.isEmpty ? '$orderId' : '$orderId:$notifiedAt';
      if (_seenReadyKeys.contains(readyKey)) return;
      _seenReadyKeys.add(readyKey);

      _seenOrders.add(orderId);
      _handleReady(orderId);
    } catch (_) {
      // ignore malformed events
    }
  }

  void _startPollingFallback() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      void applyOrders(dynamic raw) {
        if (raw == null) return;
        final data = raw is String ? json.decode(raw) : raw;
        final listData = (data['data'] as List?) ?? [];
        _refreshLastPollFromPayload(listData);
        for (final item in listData) {
          if (item is Map<String, dynamic>) {
            final orderId = item['id'] as int?;
            final notifiedAt = item['notified_at']?.toString() ?? '';
            if (notifiedAt.isNotEmpty) {
              continue;
            }
            if (orderId != null) {
              final readyKey = notifiedAt.isEmpty
                  ? '$orderId'
                  : '$orderId:$notifiedAt';
              if (_seenReadyKeys.contains(readyKey)) continue;
              _seenReadyKeys.add(readyKey);
              _seenOrders.add(orderId);
              _handleReady(orderId);
            }
          }
        }
      }

      final result = await orderService.pollOrders(
        status: 'done',
        perPage: 20,
        updatedAfter: _currentUpdatedAfter(),
        onUpdate: applyOrders,
      );

      result.fold((l) {}, (r) => applyOrders(r.data));
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

  void _stopPollingFallback() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _scheduleReconnect() {
    if (!_running.value) return;
    if (_sseReconnectTimer?.isActive ?? false) return;

    debugPrint('[Notifications] SSE reconnect scheduled');
    _sseAttempts = (_sseAttempts + 1).clamp(1, 6);
    final backoff = 2 << (_sseAttempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;

    _sseReconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      final token = await SecureStorageHelper.getAccessToken() ?? '';
      if (token.isEmpty) return;
      _startSse(token);
    });
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

  Future<void> _handleReady(int orderId) async {
    final detail = await _fetchOrderDetail(orderId);
    _showReady(orderId, detail);
  }

  Future<OrderModel?> _fetchOrderDetail(int orderId) async {
    OrderModel? order;

    void applyOrder(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        order = OrderModel.fromJson(payload);
      }
    }

    final result = await orderService.getOrderDetail(
      orderId,
      onUpdate: applyOrder,
    );

    result.fold((l) {}, (r) => applyOrder(r.data));

    return order;
  }

  void _showReady(int orderId, OrderModel? order) {
    final tableLabel = order?.table?.name;
    final totalLabel = order?.totalPrice;
    final itemCount = order?.items.length;
    final detailParts = <String>[];
    if (tableLabel != null && tableLabel.isNotEmpty) {
      detailParts.add('Meja $tableLabel');
    }
    if (itemCount != null && itemCount > 0) {
      detailParts.add('$itemCount item');
    }
    if (totalLabel != null) {
      detailParts.add('Rp ${formatIdr(totalLabel)}');
    }
    final detailText = detailParts.isEmpty
        ? ''
        : ' • ${detailParts.join(' • ')}';

    Get.snackbar(
      'Order Siap',
      'Order #$orderId sudah selesai.$detailText',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MasterColor.primary,
      colorText: MasterColor.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      onTap: (_) => Get.toNamed(Routes.ORDER_DETAIL, arguments: orderId),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _sseReconnectTimer?.cancel();
    _streamSub?.cancel();
    _client?.close(force: true);
    super.onClose();
  }
}
