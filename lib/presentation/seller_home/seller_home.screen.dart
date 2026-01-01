import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/presentation/account/account.screen.dart';
import 'package:slims/presentation/kitchen/kitchen.screen.dart';
import 'package:slims/presentation/seller_category/seller_category.screen.dart';
import 'package:slims/presentation/seller_menu/seller_menu.screen.dart';
import 'package:slims/presentation/seller_table/seller_table.screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late final PersistentTabController _controller;
  final List<Widget> _screens = const [
    KitchenScreen(),
    SellerMenuScreen(),
    SellerCategoryScreen(),
    SellerTableScreen(),
    AccountScreen(),
  ];
  final List<_SellerNavItem> _items = const [
    _SellerNavItem(icon: Icons.receipt_long, label: 'Kitchen'),
    _SellerNavItem(icon: Icons.restaurant_menu, label: 'Menu'),
    _SellerNavItem(icon: Icons.category, label: 'Kategori'),
    _SellerNavItem(icon: Icons.table_bar, label: 'Meja'),
    _SellerNavItem(icon: Icons.person, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens:
          _screens.map((screen) => CustomNavBarScreen(screen: screen)).toList(),
      itemCount: _items.length,
      customWidget: _SellerNavBar(
        controller: _controller,
        items: _items,
        activeColor: MasterColor.primary,
        inactiveColor: MasterColor.dark_40,
        backgroundColor: MasterColor.white,
        height: 52,
      ),
      confineToSafeArea: true,
      backgroundColor: MasterColor.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
    );
  }
}

class _SellerNavItem {
  final IconData icon;
  final String label;
  const _SellerNavItem({required this.icon, required this.label});
}

class _SellerNavBar extends StatelessWidget {
  final PersistentTabController controller;
  final List<_SellerNavItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final double height;

  const _SellerNavBar({
    required this.controller,
    required this.items,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: height,
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.index = i,
                      behavior: HitTestBehavior.opaque,
                      child: _SellerNavBarItem(
                        item: items[i],
                        isActive: controller.index == i,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SellerNavBarItem extends StatelessWidget {
  final _SellerNavItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const _SellerNavBarItem({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              height: 1.0,
              color: color,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
