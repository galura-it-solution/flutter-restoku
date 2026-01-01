import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/api.service.dart';

class AuthService extends GetxService {
  final String baseUrl;
  AuthService({required this.baseUrl});
  ServiceApi serviceApi = ServiceApi();

  Future<dynamic> login(String email, String password) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/auth/login',
      data: {"email": email, "password": password},
    );
    return response;
  }

  Future<dynamic> verifyOtp(String email, String code) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/auth/verify-otp',
      data: {
        "email": email,
        "code": code,
      },
    );
    return response;
  }

  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/auth/register',
      data: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      },
    );
    return response;
  }

  Future<dynamic> logout() async {
    final response = await serviceApi.postService(
      baseUrl: baseUrl,
      url: 'api/v1/auth/logout',
      data: {},
    );
    return response;
  }
}
