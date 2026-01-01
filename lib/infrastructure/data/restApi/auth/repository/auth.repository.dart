import 'dart:convert';

import 'package:slims/infrastructure/data/restApi/auth/service/auth.service.dart';
import 'package:slims/infrastructure/models/global_response.model.dart';

class LoginRepository {
  final String baseUrl;
  late final AuthService loginService;

  LoginRepository({required this.baseUrl}) {
    loginService = AuthService(baseUrl: baseUrl);
  }

  late GlobalResponseModel response;

  Future<GlobalResponseModel> login(String email, String password) async {
    var result = await loginService.login(email, password);

    result.fold(
      (l) {
        response = GlobalResponseModel(
          code: 500,
          data: null,
          message: l.toString(),
        );
      },
      (r) {
        final result = r.data is String ? json.decode(r.data) : r.data;
        response = GlobalResponseModel(
          code: r.statusCode ?? 200,
          data: result,
          message: result["message"]?.toString() ?? '',
        );
      },
    );

    return response;
  }

  Future<GlobalResponseModel> verifyOtp(String email, String code) async {
    var result = await loginService.verifyOtp(email, code);

    result.fold(
      (l) {
        response = GlobalResponseModel(
          code: 500,
          data: null,
          message: l.toString(),
        );
      },
      (r) {
        final result = r.data is String ? json.decode(r.data) : r.data;
        response = GlobalResponseModel(
          code: r.statusCode ?? 200,
          data: result,
          message: result["message"]?.toString() ?? '',
        );
      },
    );

    return response;
  }

  Future<GlobalResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    var result = await loginService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    result.fold(
      (l) {
        response = GlobalResponseModel(
          code: 500,
          data: null,
          message: l.toString(),
        );
      },
      (r) {
        final result = r.data is String ? json.decode(r.data) : r.data;
        response = GlobalResponseModel(
          code: r.statusCode ?? 200,
          data: result,
          message: result["message"]?.toString() ?? '',
        );
      },
    );

    return response;
  }

  Future<GlobalResponseModel> logout() async {
    var result = await loginService.logout();

    result.fold(
      (l) {
        response = GlobalResponseModel(
          code: 500,
          data: null,
          message: l.toString(),
        );
      },
      (r) {
        final result = r.data is String ? json.decode(r.data) : r.data;
        response = GlobalResponseModel(
          code: r.statusCode ?? 200,
          data: result,
          message: result["message"]?.toString() ?? '',
        );
      },
    );

    return response;
  }
}
