import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class SellerGuardMiddleware extends GetMiddleware {
  SellerGuardMiddleware() : super(priority: 2);

  @override
  RouteSettings? redirect(String? route) {
    final isSeller = SecureStorageHelper.isSellerCached();
    if (!isSeller) {
      return const RouteSettings(name: Routes.HOME);
    }
    return null;
  }
}
