import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';

class CartItem {
  final MenuModel menu;
  final int quantity;
  final String? note;

  CartItem({
    required this.menu,
    required this.quantity,
    this.note,
  });

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      menu: menu,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu': {
        'id': menu.id,
        'category_id': menu.categoryId,
        'name': menu.name,
        'price': menu.price,
        'description': menu.description,
        'image_object_key': menu.imageObjectKey,
        'is_active': menu.isActive,
        'stock': menu.stock,
      },
      'quantity': quantity,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menu: MenuModel.fromJson(json['menu'] as Map<String, dynamic>),
      quantity: (json['quantity'] ?? 1) as int,
      note: json['note']?.toString(),
    );
  }
}
