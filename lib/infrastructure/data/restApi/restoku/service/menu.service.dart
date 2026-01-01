import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class MenuService extends GetxService {
  final String baseUrl;
  MenuService({required this.baseUrl});

  final ServiceApi serviceApi = ServiceApi();

  Future<dynamic> getMenus({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? search,
    void Function(dynamic data)? onUpdate,
  }) async {
    final params = <String>[
      'per_page=$perPage',
      'page=$page',
      if (categoryId != null) 'category_id=$categoryId',
      if (search != null && search.isNotEmpty) 'search=$search',
    ];

    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/menus?${params.join('&')}',
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> createMenu(Map<String, dynamic> payload) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/menus',
      data: payload,
    );
    return response;
  }

  Future<dynamic> createMenuWithImage({
    required Map<String, dynamic> payload,
    required String filePath,
  }) async {
    final response = await serviceApi.postMultipartService(
      baseUrl: baseUrl,
      url: 'api/v1/menus',
      filePath: filePath,
      fieldName: 'image',
      fields: payload,
    );
    return response;
  }

  Future<dynamic> updateMenu(int id, Map<String, dynamic> payload) async {
    final response = await serviceApi.updateService(
      baseUrl: baseUrl,
      url: 'api/v1/menus/$id',
      data: payload,
    );
    return response;
  }

  Future<dynamic> deleteMenu(int id) async {
    final response = await serviceApi.deleteService(
      baseUrl: baseUrl,
      url: 'api/v1/menus/$id',
      data: {},
    );
    return response;
  }

  Future<dynamic> uploadMenuImage({
    required int id,
    required String filePath,
  }) async {
    final response = await serviceApi.postMultipartService(
      baseUrl: baseUrl,
      url: 'api/v1/menus/$id/image',
      filePath: filePath,
      fieldName: 'image',
    );
    return response;
  }
}
