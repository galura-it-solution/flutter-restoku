import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class OrderService extends GetxService {
  final String baseUrl;
  OrderService({required this.baseUrl});

  final ServiceApi serviceApi = ServiceApi();

  Future<dynamic> createOrder({
    required int tableId,
    required List<Map<String, dynamic>> items,
    required String idempotencyKey,
    String? note,
  }) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/orders',
      data: {
        'restaurant_table_id': tableId,
        'items': items,
        if (note != null) 'note': note,
      },
      headers: {
        'Idempotency-Key': idempotencyKey,
      },
    );
    return response;
  }

  Future<dynamic> getOrders({
    int page = 1,
    int perPage = 20,
    bool forceRefresh = false,
    bool useCache = true,
    void Function(dynamic data)? onUpdate,
  }) async {
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/orders?per_page=$perPage&page=$page',
      forceRefresh: forceRefresh,
      useCache: useCache,
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> getOrderDetail(
    int orderId, {
    bool forceRefresh = false,
    bool useCache = true,
    void Function(dynamic data)? onUpdate,
  }) async {
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/orders/$orderId',
      forceRefresh: forceRefresh,
      useCache: useCache,
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> getOrdersByStatus({
    required String status,
    int page = 1,
    int perPage = 20,
    String? updatedAfter,
    String? search,
    bool forceRefresh = false,
    void Function(dynamic data)? onUpdate,
  }) async {
    final updatedAfterParam = updatedAfter == null || updatedAfter.isEmpty
        ? ''
        : '&updated_after=${Uri.encodeComponent(updatedAfter)}';
    final searchParam = search == null || search.isEmpty
        ? ''
        : '&search=${Uri.encodeComponent(search)}';
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url:
          'api/v1/orders?status=$status&per_page=$perPage&page=$page$updatedAfterParam$searchParam',
      forceRefresh: forceRefresh,
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await serviceApi.patchService(
      baseUrl: baseUrl,
      url: 'api/v1/orders/$orderId/status',
      data: {'status': status},
    );
    return response;
  }

  Future<dynamic> assignOrder({
    required int orderId,
    required int assignedToUserId,
  }) async {
    final response = await serviceApi.patchService(
      baseUrl: baseUrl,
      url: 'api/v1/orders/$orderId/assign',
      data: {'assigned_to_user_id': assignedToUserId},
    );
    return response;
  }
}
