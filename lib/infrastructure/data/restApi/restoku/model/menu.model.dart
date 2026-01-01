import 'category.model.dart';

class MenuModel {
  final int id;
  final int categoryId;
  final String name;
  final num price;
  final String? description;
  final String? imageObjectKey;
  final String? imageUrl;
  final bool isActive;
  final int? stock;
  final CategoryModel? category;

  MenuModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageObjectKey,
    this.imageUrl,
    required this.isActive,
    this.stock,
    this.category,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: (json['id'] ?? 0) as int,
      categoryId: (json['category_id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? 0) as num,
      description: json['description']?.toString(),
      imageObjectKey: json['image_object_key']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      stock: json['stock'] == null ? null : (json['stock'] as num).toInt(),
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isAvailable => isActive && (stock == null || stock! > 0);
}
