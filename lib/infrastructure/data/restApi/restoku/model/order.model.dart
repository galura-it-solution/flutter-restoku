import 'order_item.model.dart';
import 'table.model.dart';

class OrderModel {
  final int id;
  final int restaurantTableId;
  final String status;
  final int? queueNumber;
  final int? currentProcessingQueueNumber;
  final num totalPrice;
  final num subtotal;
  final num serviceCharge;
  final num tax;
  final String? note;
  final String? assignedTo;
  final int? assignedToUserId;
  final TableModel? table;
  final List<OrderItemModel> items;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.restaurantTableId,
    required this.status,
    this.queueNumber,
    this.currentProcessingQueueNumber,
    required this.totalPrice,
    required this.subtotal,
    required this.serviceCharge,
    required this.tax,
    this.note,
    this.assignedTo,
    this.assignedToUserId,
    this.table,
    required this.items,
    this.updatedAt,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map<String, dynamic>>()
            .map(OrderItemModel.fromJson)
            .toList()
        : <OrderItemModel>[];

    final updatedAtRaw = json['updated_at']?.toString();
    final updatedAt =
        updatedAtRaw == null ? null : DateTime.tryParse(updatedAtRaw);
    final createdAtRaw = json['created_at']?.toString();
    final createdAt =
        createdAtRaw == null ? null : DateTime.tryParse(createdAtRaw);

    return OrderModel(
      id: (json['id'] ?? 0) as int,
      restaurantTableId: (json['restaurant_table_id'] ?? 0) as int,
      status: (json['status'] ?? '').toString(),
      queueNumber: json['queue_number'] is int ? json['queue_number'] as int : null,
      currentProcessingQueueNumber:
          json['current_processing_queue_number'] is int
              ? json['current_processing_queue_number'] as int
              : null,
      totalPrice: (json['total_price'] ?? 0) as num,
      subtotal: (json['subtotal'] ?? 0) as num,
      serviceCharge: (json['service_charge'] ?? 0) as num,
      tax: (json['tax'] ?? 0) as num,
      note: json['note']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      assignedToUserId: json['assigned_to_user_id'] is int
          ? json['assigned_to_user_id'] as int
          : int.tryParse(json['assigned_to_user_id']?.toString() ?? ''),
      table: json['table'] is Map<String, dynamic>
          ? TableModel.fromJson(json['table'] as Map<String, dynamic>)
          : null,
      items: items,
      updatedAt: updatedAt,
      createdAt: createdAt,
    );
  }
}
