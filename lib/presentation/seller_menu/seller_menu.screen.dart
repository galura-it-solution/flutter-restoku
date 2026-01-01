import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/seller_menu/controllers/seller_menu.controller.dart';
import 'package:slims/presentation/seller_menu/widgets/menu_form_dialog.dart';
import 'package:slims/presentation/seller_menu/widgets/menu_list_view.dart';

class SellerMenuScreen extends StatelessWidget {
  const SellerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerMenuController());
    void openMenuForm({MenuModel? menu}) {
      showDialog(
        context: context,
        builder: (context) => MenuFormDialog(
          controller: controller,
          menu: menu,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: MasterColor.white,
        elevation: 0,
        title: const Text(
          'Kelola Menu',
          style: TextStyle(
            color: MasterColor.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchMenus,
            icon: const Icon(Icons.refresh, color: MasterColor.dark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MasterColor.primary,
        onPressed: () => openMenuForm(),
        child: const Icon(Icons.add, color: MasterColor.white),
      ),
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg_2.jpg',
        overlayDark: 0.08,
        overlayLight: 0.92,
        child: MenuListView(
          controller: controller,
          onEdit: (menu) => openMenuForm(menu: menu),
        ),
      ),
    );
  }
}
