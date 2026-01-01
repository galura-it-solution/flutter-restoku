import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class TableService extends GetxService {
  final String baseUrl;
  TableService({required this.baseUrl});

  final ServiceApi serviceApi = ServiceApi();

  Future<dynamic> getTables({
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
    bool useCache = true,
    void Function(dynamic data)? onUpdate,
  }) async {
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/tables?per_page=$perPage&page=$page',
      forceRefresh: forceRefresh,
      useCache: useCache,
      onUpdate: onUpdate,
    );
    return response;
  }

  Future<dynamic> createTable(Map<String, dynamic> payload) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/tables',
      data: payload,
    );
    return response;
  }

  Future<dynamic> updateTable(int id, Map<String, dynamic> payload) async {
    final response = await serviceApi.updateService(
      baseUrl: baseUrl,
      url: 'api/v1/tables/$id',
      data: payload,
    );
    return response;
  }

  Future<dynamic> deleteTable(int id) async {
    final response = await serviceApi.deleteService(
      baseUrl: baseUrl,
      url: 'api/v1/tables/$id',
      data: {},
    );
    return response;
  }
}
