import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class UserService extends GetxService {
  final String baseUrl;
  UserService({required this.baseUrl});

  final ServiceApi serviceApi = ServiceApi();

  Future<dynamic> getUsers({
    String? role,
    int page = 1,
    int perPage = 50,
    void Function(dynamic data)? onUpdate,
  }) async {
    final roleParam = role == null || role.isEmpty
        ? ''
        : '&role=${Uri.encodeComponent(role)}';
    final response = await serviceApi.getService(
      baseUrl: baseUrl,
      url: 'api/v1/users?per_page=$perPage&page=$page$roleParam',
      onUpdate: onUpdate,
    );
    return response;
  }
}
