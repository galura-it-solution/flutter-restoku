import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/detail_menu/controllers/detail_menu.controller.dart';
import 'package:slims/presentation/keranjang/controllers/keranjang.controller.dart';

class DetailMenuScreen extends StatelessWidget {
  const DetailMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetailMenuController>();
    final cartController = Get.find<KeranjangController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Detail Menu'),
        backgroundColor: MasterColor.white,
        elevation: 0,
      ),
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_2.jpg',
        overlayDark: 0.1,
        overlayLight: 0.9,
        child: Obx(
          () {
            final menu = controller.menu.value;
            if (menu == null) {
              return const Center(child: Text('Menu tidak ditemukan.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MasterColor.dark_10,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                          ? Image.network(
                              menu.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _MenuDetailFallback();
                              },
                            )
                          : _MenuDetailFallback(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (menu.category != null)
                    Text(
                      menu.category!.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: MasterColor.dark_40,
                      ),
                    ),
                  if (menu.stock != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok: ${menu.stock}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: MasterColor.dark_40,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    menu.description ??
                        'Menu lezat dengan bahan pilihan terbaik.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: MasterColor.dark_50,
                      height: 1.4,
                    ),
                  ),
                  if (!menu.isAvailable) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: MasterColor.dark_10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Menu sedang tidak tersedia',
                        style: TextStyle(
                          color: MasterColor.dark_60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MasterColor.primary_10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga',
                          style: TextStyle(
                            fontSize: 14,
                            color: MasterColor.dark_50,
                          ),
                        ),
                        Text(
                          'Rp ${formatIdr(menu.price)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MasterColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: menu.isAvailable
                          ? () => cartController.addToCart(menu)
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        menu.isAvailable
                            ? 'Tambah ke Pesanan'
                            : 'Tidak Tersedia',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: menu.isAvailable
                            ? MasterColor.primary
                            : MasterColor.dark_30,
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
    );
  }
}

class _MenuDetailFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.restaurant_menu,
        size: 80,
        color: MasterColor.dark_30,
      ),
    );
  }
}
