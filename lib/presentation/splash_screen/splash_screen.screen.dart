import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';
import 'package:get/get.dart';
import 'controllers/splash_screen.controller.dart';

class SplashScreenScreen extends GetView<SplashScreenController> {
  const SplashScreenScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Get.find<SplashScreenController>();
    return Scaffold(
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_4.jpg',
        overlayDark: 0.35,
        overlayLight: 0.2,
        child: Stack(
          children: [
            Center(
              child: GetBuilder<SplashScreenController>(
                builder: (_) => FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: ScaleTransition(
                    scale: controller.scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: MasterColor.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: MasterColor.white,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Restoku',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: MasterColor.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pesan cepat, nikmati sajian terbaik',
                          style: TextStyle(
                            color: MasterColor.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 20,
              right: 20,
              child: CustomText(
                "Versi Beta 0.0.1",
                color: MasterColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
