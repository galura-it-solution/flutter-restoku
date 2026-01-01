import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class CategoryService extends GetxService {
  final String baseUrl;
  CategoryService({required this.baseUrl});

  final ServiceApi serviceApi = ServiceApi();

  Future<dynamic> getCategories({
    int page = 1,
    int perPage = 20,
    void Function(dynamic data)? onUpdate,
  }) async {
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/categories?per_page=$perPage&page=$page',
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> createCategory(Map<String, dynamic> payload) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/categories',
      data: payload,
    );
    return response;
  }

  Future<dynamic> createCategoryWithImage({
    required Map<String, dynamic> payload,
    required String filePath,
  }) async {
    final response = await serviceApi.postMultipartService(
      baseUrl: baseUrl,
      url: 'api/v1/categories',
      filePath: filePath,
      fieldName: 'image',
      fields: payload,
    );
    return response;
  }

  Future<dynamic> updateCategory(int id, Map<String, dynamic> payload) async {
    final response = await serviceApi.updateService(
      baseUrl: baseUrl,
      url: 'api/v1/categories/$id',
      data: payload,
    );
    return response;
  }

  Future<dynamic> deleteCategory(int id) async {
    final response = await serviceApi.deleteService(
      baseUrl: baseUrl,
      url: 'api/v1/categories/$id',
      data: {},
    );
    return response;
  }

  Future<dynamic> uploadCategoryImage({
    required int id,
    required String filePath,
  }) async {
    final response = await serviceApi.postMultipartService(
      baseUrl: baseUrl,
      url: 'api/v1/categories/$id/image',
      filePath: filePath,
      fieldName: 'image',
    );
    return response;
  }
}
