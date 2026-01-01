import 'dart:convert';

import 'package:get/get.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';

class AccountController extends GetxController {
  final totalOrders = 0.obs;
  final orderLoading = false.obs;
  final orderError = ''.obs;

  late final OrderService orderService;
  bool _totalFetched = false;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
  }

  Future<void> ensureTotalOrders() async {
    if (_totalFetched) return;
    _totalFetched = true;
    await fetchTotalOrders();
  }

  Future<void> fetchTotalOrders() async {
    orderLoading.value = true;
    orderError.value = '';

    int? total = await _fetchTotalFromMeta();

    total ??= await _fetchTotalFromList();

    if (total != null) {
      totalOrders.value = total;
    }

    orderLoading.value = false;
  }

  Future<int?> _fetchTotalFromMeta() async {
    final result = await orderService.getOrders(
      perPage: 1,
      forceRefresh: true,
      useCache: false,
    );

    int? total;
    result.fold(
      (l) {
        orderError.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat total order.',
        );
      },
      (r) {
        total = _extractTotal(r.data);
      },
    );
    return total;
  }

  Future<int?> _fetchTotalFromList() async {
    final result = await orderService.getOrders(
      perPage: 200,
      forceRefresh: true,
      useCache: false,
    );

    int? total;
    result.fold(
      (l) {
        orderError.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat total order.',
        );
      },
      (r) {
        total = _extractListCount(r.data);
      },
    );
    return total;
  }

  int? _extractTotal(dynamic raw) {
    final resolved = raw is String ? json.decode(raw) : raw;
    if (resolved is Map<String, dynamic>) {
      final meta = resolved['meta'];
      if (meta is Map<String, dynamic>) {
        final total = _readTotalFromMap(meta);
        if (total != null) return total;
      }
      final pagination = resolved['pagination'];
      if (pagination is Map<String, dynamic>) {
        final total = _readTotalFromMap(pagination);
        if (total != null) return total;
      }
      if (resolved['total'] != null) {
        return int.tryParse(resolved['total'].toString());
      }
      final data = resolved['data'];
      if (data is List) return data.length;
    }
    if (resolved is List) return resolved.length;
    return null;
  }

  int? _extractListCount(dynamic raw) {
    final resolved = raw is String ? json.decode(raw) : raw;
    if (resolved is Map<String, dynamic>) {
      final data = resolved['data'];
      if (data is List) return data.length;
    }
    if (resolved is List) return resolved.length;
    return null;
  }

  int? _readTotalFromMap(Map<String, dynamic> map) {
    const keys = [
      'total',
      'total_items',
      'total_data',
      'total_records',
      'total_count',
    ];
    for (final key in keys) {
      if (map[key] != null) {
        return int.tryParse(map[key].toString());
      }
    }
    return null;
  }
}
