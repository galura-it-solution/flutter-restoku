import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';
import 'package:slims/presentation/login/sections/form_login.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_2.jpg',
        overlayDark: 0.25,
        overlayLight: 0.85,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isPortrait = height > width;

            return SingleChildScrollView(
              controller: controller.scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: isPortrait ? 80 : 40,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 24),
                      FormLogin(controller: controller, width: width),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            color: MasterColor.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: MasterColor.white,
            size: 46,
          ),
        ),
        const SizedBox(height: 16),
        CustomText.title(
          'Masuk ke Restoku',
          color: MasterColor.white,
          fontSize: 26,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CustomText(
          'Gunakan email dan password untuk menerima OTP login.',
          color: MasterColor.white.withValues(alpha: 0.9),
          fontSize: 14,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
