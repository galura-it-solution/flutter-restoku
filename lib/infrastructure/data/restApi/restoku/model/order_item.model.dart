import 'menu.model.dart';

class OrderItemModel {
  final int id;
  final int menuId;
  final String? menuName;
  final String? menuDescription;
  final int quantity;
  final num price;
  final num subtotal;
  final String? notes;
  final MenuModel? menu;

  OrderItemModel({
    required this.id,
    required this.menuId,
    this.menuName,
    this.menuDescription,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.notes,
    this.menu,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] ?? 0) as int,
      menuId: (json['menu_id'] ?? 0) as int,
      menuName: json['menu_name']?.toString(),
      menuDescription: json['menu_description']?.toString(),
      quantity: (json['quantity'] ?? 0) as int,
      price: (json['price'] ?? 0) as num,
      subtotal: (json['subtotal'] ?? 0) as num,
      notes: json['notes']?.toString(),
      menu: json['menu'] is Map<String, dynamic>
          ? MenuModel.fromJson(json['menu'] as Map<String, dynamic>)
          : null,
    );
  }
}
