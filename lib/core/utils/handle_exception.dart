import 'package:slims/infrastructure/models/global_response.model.dart';
import 'package:dio/dio.dart';
import 'package:slims/config.dart';

class HandleException {
  final env = ConfigEnvironments.getEnvironments()['env'];

  GlobalResponseModel handleDioError(dioError) {
    // Default error message
    GlobalResponseModel errorMessage = const GlobalResponseModel(
      code: 500,
      message: 'Sistem sedang mengalami gangguan',
      data: null,
    );

    // Check if there's a response and data in the error
    if (dioError.response != null && dioError.response?.data is Map) {
      final data = dioError.response?.data as Map<String, dynamic>;

      // Check if the response contains a 'message'
      if (data.containsKey('message')) {
        errorMessage = GlobalResponseModel(
          code: dioError.response?.statusCode ?? 500,
          message: data['message'],
          data: data['data'],
        );
      }
    }

    // Handle specific error types and update the errorMessage accordingly
    if (errorMessage.message == 'Sistem sedang mengalami gangguan') {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = const GlobalResponseModel(
            code: 408,
            message: 'Waktu koneksi dengan server API habis',
            data: null,
          );
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = const GlobalResponseModel(
            code: 408,
            message: 'Waktu pengiriman ke server API habis',
            data: null,
          );
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = const GlobalResponseModel(
            code: 408,
            message: 'Waktu penerimaan dari server API habis',
            data: null,
          );
          break;
        case DioExceptionType.cancel:
          errorMessage = const GlobalResponseModel(
            code: 400,
            message: 'Permintaan ke server API dibatalkan',
            data: null,
          );
          break;
        case DioExceptionType.unknown:
          errorMessage = const GlobalResponseModel(
            code: 500,
            message:
                'Oops, terjadi kesalahan! Mohon tunggu, layanan kami sedang dalam perbaikan.',
            data: null,
          );
          break;
      }
    }

    return errorMessage;
  }
}
