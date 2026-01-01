import 'dart:convert';

class ApiErrorMessage {
  static String from(
    dynamic error, {
    String fallback = 'Terjadi kesalahan.',
  }) {
    if (error == null) return fallback;

    if (error is String) {
      try {
        final decoded = json.decode(error);
        if (decoded is Map<String, dynamic>) {
          final message = decoded['message']?.toString();
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }
      } catch (_) {
        // ignore decode error
      }

      return error.isNotEmpty ? error : fallback;
    }

    if (error is Map<String, dynamic>) {
      final message = error['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return error.toString().isNotEmpty ? error.toString() : fallback;
  }
}
