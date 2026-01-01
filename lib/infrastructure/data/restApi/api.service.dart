import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart' as get_x;
import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/models/global_response.model.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:slims/core/utils/handle_exception.dart';
import 'package:logger/logger.dart';

import '../../navigation/routes.dart';

class ServiceApi {
  final Dio _dio = Dio();

  HandleException exceptionService = HandleException();
  final Logger _logger = Logger();
  Future<Either<String, dynamic>> getService({
    required baseUrl,
    required url,
    String? directToken,
    Map<String, String>? headers,
    bool useCache = true,
    bool forceRefresh = false,
    bool staleWhileRevalidate = true,
    void Function(dynamic data)? onUpdate,
  }) async {
    String token = await SecureStorageHelper.generateToken();
    final resolvedToken = directToken ?? token;
    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $resolvedToken',
        ...?headers,
      };
      final requestUrl = '$baseUrl/$url';
      Future<Response<dynamic>> fetchDirect() {
        return _dio.get(
          requestUrl,
          options: Options(
            contentType: 'application/json',
            headers: requestHeaders,
          ),
        );
      }

      if (!useCache) {
        response = await fetchDirect();

        return right(response);
      }

      final user = await SecureStorageHelper.getUser();
      final userKey =
          user?['id']?.toString() ?? resolvedToken.hashCode.toString();
      final queryKey = {
        'method': 'GET',
        'url': requestUrl,
        'user': userKey,
        if (headers != null && headers.isNotEmpty) 'headers': headers,
      };

      final query = Query<dynamic>(
        key: queryKey,
        queryFn: () async {
          final response = await _dio.get(
            requestUrl,
            options: Options(
              contentType: 'application/json',
              headers: requestHeaders,
            ),
          );
          return response.data;
        },
      );

      QueryState<dynamic> state;
      try {
        state = forceRefresh ? await query.refetch() : await query.result;
      } catch (e) {
        if (e.toString().contains('does not support tagging')) {
          response = await fetchDirect();
          return right(response);
        }
        rethrow;
      }
      final fetchedRecently =
          DateTime.now().difference(state.timeCreated) < const Duration(seconds: 1);
      final shouldBackgroundRefresh =
          staleWhileRevalidate &&
          !forceRefresh &&
          onUpdate != null &&
          !fetchedRecently;

      if (shouldBackgroundRefresh) {
        final hasInitialData = state.data != null;
        bool skippedInitial = false;
        StreamSubscription<QueryState<dynamic>>? sub;
        sub = query.stream.listen((next) {
          if (hasInitialData && !skippedInitial) {
            skippedInitial = true;
            return;
          }
          if (next.status == QueryStatus.error) {
            sub?.cancel();
            return;
          }
          if (next.status == QueryStatus.success && next.data != null) {
            onUpdate.call(next.data);
            sub?.cancel();
          }
        });
        query.refetch();
      }

      if (state.data != null) {
        return right(
          Response(
            data: state.data,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: url,
              baseUrl: baseUrl,
              method: 'GET',
            ),
          ),
        );
      }

      final error = state.error;
      if (error != null &&
          error.toString().contains('does not support tagging')) {
        response = await fetchDirect();
        return right(response);
      }
      if (error is DioException) {
        if (error.response?.statusCode == 401) {
          final result = await SecureStorageHelper.removeToken();
          if (result) {
            get_x.Get.offAllNamed(Routes.LOGIN);
          }
        }

        GlobalResponseModel errorResponse = exceptionService.handleDioError(
          error,
        );
        return left(jsonEncode(errorResponse.toJson()));
      }

      return left(error?.toString() ?? 'Request error');
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      _logApiError(
        method: 'GET',
        url: '$baseUrl/$url',
        payload: null,
        dioError: dioError,
      );
      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      _logger.e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      _logger.e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  void _invalidateGetCache(String baseUrl) {
    try {
      CachedQuery.instance.invalidateCache(
        filterFn: (unencodedKey, _) {
          if (unencodedKey is Map) {
            final method = unencodedKey['method']?.toString();
            final url = unencodedKey['url']?.toString() ?? '';
            return method == 'GET' && url.startsWith(baseUrl);
          }
          return false;
        },
      );
    } catch (e, s) {
      Logger().w(
        'Cache store does not support tagging; falling back to full cache clear.',
        error: e,
        stackTrace: s,
      );
      CachedQuery.instance.deleteCache(deleteStorage: true);
    }
  }

  Future<Either<String, dynamic>> postService({
    required baseUrl,
    required url,
    required data,
    Map<String, String>? headers,
  }) async {
    String token = await SecureStorageHelper.generateToken();

    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      response = await _dio.post(
        '$baseUrl/$url',
        data: data,
        options: Options(
          contentType: 'application/json',
          headers: requestHeaders,
        ),
      );

      _invalidateGetCache(baseUrl);
      return right(response);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      _logApiError(
        method: 'POST',
        url: '$baseUrl/$url',
        payload: data,
        dioError: dioError,
      );
      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      _logger.e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      _logger.e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  Future<Either<String, dynamic>> updateService({
    required baseUrl,
    required url,
    required data,
    Map<String, String>? headers,
  }) async {
    String token = await SecureStorageHelper.generateToken();
    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      response = await _dio.put(
        '$baseUrl/$url',
        data: data,
        options: Options(
          contentType: 'application/json',
          headers: requestHeaders,
        ),
      );

      _invalidateGetCache(baseUrl);
      return right(response);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      _logApiError(
        method: 'PUT',
        url: '$baseUrl/$url',
        payload: data,
        dioError: dioError,
      );
      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      _logger.e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      _logger.e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  Future<Either<String, dynamic>> patchService({
    required baseUrl,
    required url,
    required data,
    Map<String, String>? headers,
  }) async {
    String token = await SecureStorageHelper.generateToken();
    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      response = await _dio.patch(
        '$baseUrl/$url',
        data: data,
        options: Options(
          contentType: 'application/json',
          headers: requestHeaders,
        ),
      );

      _invalidateGetCache(baseUrl);
      return right(response);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      _logApiError(
        method: 'PATCH',
        url: '$baseUrl/$url',
        payload: data,
        dioError: dioError,
      );
      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      _logger.e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      _logger.e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  Future<Either<String, dynamic>> deleteService({
    required baseUrl,
    required url,
    required data,
    Map<String, String>? headers,
  }) async {
    String token = await SecureStorageHelper.generateToken();
    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      response = await _dio.delete(
        '$baseUrl/$url',
        data: data,
        options: Options(
          contentType: 'application/json',
          headers: requestHeaders,
        ),
      );

      _invalidateGetCache(baseUrl);
      return right(response);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      Logger().e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      Logger().e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  Future<Either<String, dynamic>> postMultipartService({
    required baseUrl,
    required url,
    required String filePath,
    String fieldName = 'image',
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
  }) async {
    String token = await SecureStorageHelper.generateToken();
    Response response;
    try {
      final requestHeaders = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      final formData = FormData.fromMap({
        ...?fields,
        fieldName: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      response = await _dio.post(
        '$baseUrl/$url',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: requestHeaders,
        ),
      );

      _invalidateGetCache(baseUrl);
      return right(response);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        final result = await SecureStorageHelper.removeToken();
        if (result) {
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
      }

      _logApiError(
        method: 'POST',
        url: '$baseUrl/$url',
        payload: {
          'file_path': filePath,
          'field_name': fieldName,
          'fields': fields,
        },
        dioError: dioError,
      );
      GlobalResponseModel error = exceptionService.handleDioError(dioError);
      _logger.e(error);
      return left(jsonEncode(error.toJson()));
    } catch (e, s) {
      _logger.e(e, stackTrace: s);
      return left(e.toString());
    }
  }

  void _logApiError({
    required String method,
    required String url,
    required dynamic payload,
    required DioException dioError,
  }) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;
    _logger.e(
      'API error',
      error: {
        'method': method,
        'url': url,
        'status': statusCode,
        'payload': _safeJson(payload),
        'response': _safeJson(responseData),
      },
      stackTrace: dioError.stackTrace,
    );
  }

  String? _safeJson(dynamic value) {
    if (value == null) return null;
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }
}
