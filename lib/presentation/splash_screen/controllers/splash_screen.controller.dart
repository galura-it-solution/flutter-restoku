import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SplashScreenController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> textFadeAnimation;
  late Animation<Offset> textSlideAnimation;

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    // Text animation (1.2s–2.2s)
    textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    animationController.forward();

    animationController.forward();

    _navigateTo();
  }

  void _navigateTo() async {
    Future.delayed(const Duration(seconds: 2), () async {
      final token = await SecureStorageHelper.getAccessToken();
      if ((token ?? '').isEmpty) {
        Get.offAllNamed(Routes.MAIN_MENU);
        return;
      }

      final isSeller = await SecureStorageHelper.isSeller();
      Get.offAllNamed(isSeller ? Routes.SELLER_HOME : Routes.HOME);
    });
  }
}
