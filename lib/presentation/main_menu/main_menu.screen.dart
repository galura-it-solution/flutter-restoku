import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';
import 'controllers/main_menu.controller.dart';

class MainMenuScreen extends GetView<MainMenuController> {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_3.jpg',
        overlayDark: 0.3,
        overlayLight: 0.2,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: MasterColor.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: MasterColor.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 24),
                CustomText.title(
                  'Restoku',
                  color: MasterColor.white,
                  fontSize: 28,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesan cepat, pantau status, dan nikmati menu terbaik.',
                  style: TextStyle(
                    color: MasterColor.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  onPressed: () async {
                    await SecureStorageHelper.checkTokenBeforeRouting();
                  },
                  text: 'Mulai Pesan',
                  height: 54,
                  width: double.infinity,
                  borderRadius: 14,
                  loading: false,
                  backgroundColor: MasterColor.white,
                  textColor: MasterColor.dark,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
