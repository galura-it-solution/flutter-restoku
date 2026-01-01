class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
