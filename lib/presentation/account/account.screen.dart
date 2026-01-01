import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/modal_dialog.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';
import 'controllers/account.controller.dart';

class AccountScreen extends GetView<AccountController> {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSellerFuture = SecureStorageHelper.isSeller();
    return FutureBuilder<bool>(
      future: isSellerFuture,
      builder: (context, sellerSnapshot) {
        final isSeller = sellerSnapshot.data ?? false;
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: FoodBackground(
              imagePath: 'lib/assets/images/food_bg.jpg',
              overlayDark: 0.1,
              overlayLight: 0.9,
              child: FutureBuilder(
                future: SecureStorageHelper.getUser(),
                builder: (context, snapshot) {
                  final user = snapshot.data as Map<String, dynamic>?;
                  final name = user?['name']?.toString() ?? 'Guest';
                  final email = user?['email']?.toString() ?? '-';
                  final role = user?['role']?.toString() ?? 'customer';
        
                  if (isSeller) {
                    controller.ensureTotalOrders();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: MasterColor.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: MasterColor.primary_10,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: MasterColor.primary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText.title(
                                  name,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  email,
                                  color: MasterColor.dark_50,
                                  fontSize: 13,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MasterColor.primary_10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      color: MasterColor.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MasterColor.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: MasterColor.dark,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gunakan OTP untuk login, pastikan email aktif agar order tetap aman.',
                            style: TextStyle(color: MasterColor.dark_50),
                          ),
                        ],
                      ),
                    ),
                        if (isSeller) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: MasterColor.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    color: MasterColor.primary_10,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: MasterColor.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Riwayat Order',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: MasterColor.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Obx(
                                        () {
                                          if (controller.orderLoading.value) {
                                            return const Text(
                                              'Memuat total order...',
                                              style: TextStyle(
                                                color: MasterColor.dark_50,
                                              ),
                                            );
                                          }
                                          if (controller.orderError.value
                                              .isNotEmpty) {
                                            return Text(
                                              controller.orderError.value,
                                              style: const TextStyle(
                                                color: MasterColor.dark_50,
                                              ),
                                            );
                                          }
                                          return Text(
                                            '${controller.totalOrders.value} order',
                                            style: const TextStyle(
                                              color: MasterColor.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(Routes.ORDER_HISTORY),
                                  child: const Text('Riwayat Order'),
                                ),
                              ],
                            ),
                          ),
                        ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          showConfirmDialog(
                            title: 'Keluar Akun',
                            message: 'Yakin ingin keluar dari akun ini?',
                            labelCancel: 'Batal',
                            labelConfirm: 'Keluar',
                            onConfirm: () async {
                              final result =
                                  await SecureStorageHelper.removeToken();
                              if (result) {
                                Get.offAllNamed(Routes.MAIN_MENU);
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Keluar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MasterColor.danger,
                          foregroundColor: MasterColor.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
