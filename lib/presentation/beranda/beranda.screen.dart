import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/beranda/controllers/beranda.controller.dart';
import 'package:slims/presentation/keranjang/controllers/keranjang.controller.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BerandaController());
    final cartController = Get.find<KeranjangController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FoodBackground(
          imagePath: 'lib/assets/images/food_bg_2.jpg',
          overlayDark: 0.12,
          overlayLight: 0.9,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: MasterColor.white.withValues(alpha: 0.95),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.searchController,
                      onChanged: controller.searchMenus,
                      decoration: InputDecoration(
                        hintText: 'Cari menu favorit... ',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: MasterColor.dark_10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: Obx(
                        () => ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'Semua',
                              imageUrl: null,
                              selected:
                                  controller.selectedCategoryId.value == null,
                              onTap: () => controller.applyCategory(null),
                            ),
                            ...controller.categories.map(
                              (category) => _CategoryChip(
                                label: category.name,
                                imageUrl: category.imageUrl,
                                selected:
                                    controller.selectedCategoryId.value ==
                                    category.id,
                                onTap: () =>
                                    controller.applyCategory(category.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  return AsyncStateView(
                    loading:
                        controller.isLoading.value && controller.menus.isEmpty,
                    errorMessage: controller.errorMessage.value,
                    isEmpty: controller.menus.isEmpty,
                    emptyMessage: 'Menu belum tersedia.',
                    onRetry: () => controller.fetchMenus(loadMore: false),
                    onRefresh: () async {
                      controller.page.value = 1;
                      controller.hasMore.value = true;
                      await controller.fetchCategories();
                      await controller.fetchMenus(loadMore: false);
                    },
                    child: GridView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: controller.menus.length,
                      itemBuilder: (context, index) {
                        final menu = controller.menus[index];
                        return _MenuCard(
                          menu: menu,
                          onAdd: () => cartController.addToCart(menu),
                          onTap: () {
                            Get.toNamed(Routes.DETAIL_MENU, arguments: menu);
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? MasterColor.primary : MasterColor.dark_10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? MasterColor.primary : MasterColor.dark_20,
            ),
          ),
          child: Row(
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MasterColor.white,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 12,
                          color: MasterColor.dark_40,
                        );
                      },
                    ),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: selected ? MasterColor.white : MasterColor.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.menu,
    required this.onAdd,
    required this.onTap,
  });

  final MenuModel menu;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: menu.isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: menu.isAvailable ? 1 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: MasterColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                            ? Image.network(
                                menu.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _MenuImageFallback();
                                },
                              )
                            : _MenuImageFallback(),
                      ),
                      if (!menu.isAvailable)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: MasterColor.dark_60,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Tidak tersedia',
                              style: TextStyle(
                                color: MasterColor.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.description ?? 'Menu spesial dari dapur Restoku.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MasterColor.dark_40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${formatIdr(menu.price)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: MasterColor.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: menu.isAvailable
                              ? MasterColor.primary
                              : MasterColor.dark_30,
                          onPressed: menu.isAvailable ? onAdd : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MasterColor.dark_10,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 54,
          color: MasterColor.dark_30,
        ),
      ),
    );
  }
}
