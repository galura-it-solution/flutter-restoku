// ignore_for_file: unused_field

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;
import 'package:slims/core/utils/secure_storage.dart';
import 'package:logger/logger.dart';

class AuthorizationInterceptor extends Interceptor {
  AuthorizationInterceptor();
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String token = await SecureStorageHelper.generateToken();
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      directNetworkErrorPage();
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    bool isError = response.statusCode != 200 && response.statusCode != 201;
    if (isError) {
      directNetworkErrorPage();
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    bool isErrorType =
        err.type == DioExceptionType.badResponse ||
        err.type == DioExceptionType.badCertificate ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.cancel ||
        err.type == DioExceptionType.unknown;

    if (isErrorType || err.error is HttpException) {
      directNetworkErrorPage();
    }
    handler.next(err);
  }

  void directNetworkErrorPage() async {
    final byPassPages = [];

    if (byPassPages.contains(g.Get.currentRoute)) return;
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e, s) {
      Logger().e(e, stackTrace: s);
      return false;
    }
    return false;
  }
}
