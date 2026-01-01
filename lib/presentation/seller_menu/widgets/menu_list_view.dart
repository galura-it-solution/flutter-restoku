import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/presentation/@shared/widgets/async_state_view.dart';
import 'package:slims/presentation/seller_menu/controllers/seller_menu.controller.dart';
import 'package:slims/presentation/seller_menu/widgets/menu_list_item.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';

class MenuListView extends StatelessWidget {
  const MenuListView({
    super.key,
    required this.controller,
    required this.onEdit,
  });

  final SellerMenuController controller;
  final ValueChanged<MenuModel> onEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AsyncStateView(
        loading: controller.loading.value,
        errorMessage: controller.errorMessage.value,
        isEmpty: controller.menus.isEmpty,
        emptyMessage: 'Belum ada menu.',
        onRetry: controller.fetchMenus,
        onRefresh: () => controller.fetchMenus(),
        child: ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount:
              controller.menus.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.menus.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final menu = controller.menus[index];
            final isDeleting = controller.deletingId.value == menu.id;
            return MenuListItem(
              menu: menu,
              isDeleting: isDeleting,
              onEdit: () => onEdit(menu),
              onDelete: () => controller.deleteMenu(menu.id),
            );
          },
        ),
      );
    });
  }
}
