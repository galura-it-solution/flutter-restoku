import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:slims/config.dart';
import 'package:slims/core/utils/shared_preference.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class SecureStorageHelper {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'ACCESS_TOKEN';
  static String? _cachedRole;

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _keyAccessToken);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    CachedQuery.instance.deleteCache(deleteStorage: true);
  }

  static Future<void> saveUser(dynamic data) async {
    await SharedPrefsHelper.saveModel('auth_user', data);
    _cachedRole = data?['role']?.toString();
  }

  static Future<dynamic> getUser() async {
    return await SharedPrefsHelper.getModel('auth_user');
  }

  static Future<String> getUserRole() async {
    final user = await getUser();
    final role = user?['role']?.toString() ?? 'customer';
    _cachedRole = role;
    return role;
  }

  static Future<bool> isSeller() async {
    final role = await getUserRole();
    return ['admin', 'staff', 'kitchen'].contains(role);
  }

  static bool isSellerCached() {
    final role = _cachedRole ?? 'customer';
    return ['admin', 'staff', 'kitchen'].contains(role);
  }

  static String generateBaseUrl() {
    return ConfigEnvironments.getEnvironments()['url_api'].toString();
  }

  static Future<String> generateToken() async {
    final tokenVal = await SecureStorageHelper.getAccessToken();
    return tokenVal ?? '';
  }

  static Future<bool> removeToken() async {
    await SecureStorageHelper.deleteAccessToken();
    await SharedPrefsHelper.remove('auth_user');
    CachedQuery.instance.deleteCache(deleteStorage: true);
    return true;
  }

  static Future<void> checkTokenBeforeRouting() async {
    final token = await SecureStorageHelper.getAccessToken() ?? '';

    if (token.isNotEmpty) {
      final isSellerRole = await isSeller();
      Get.offAllNamed(isSellerRole ? Routes.SELLER_HOME : Routes.HOME);
    } else {
      Get.toNamed(Routes.LOGIN);
    }
  }
}
