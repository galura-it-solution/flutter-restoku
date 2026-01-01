import 'package:flutter_svg/svg.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';
import 'package:slims/presentation/screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/home.controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final PersistentTabController persistentTabController =
        PersistentTabController(initialIndex: 0);

    List<Widget> buildScreens() {
      return const [
        BerandaScreen(),
        KeranjangScreen(),
        SizedBox.shrink(),
        OrderHistoryScreen(),
        AccountScreen(),
      ];
    }

    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/home.svg',
                colorFilter: ColorFilter.mode(
                  MasterColor.success,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          inactiveIcon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/home.svg',
                colorFilter: ColorFilter.mode(theme.hintColor, BlendMode.srcIn),
              ),
            ),
          ),
          activeColorPrimary: colors.primary,
          inactiveColorPrimary: theme.hintColor,
          title: 'Menu',
          textStyle: const TextStyle(fontSize: 10, height: 2),
        ),
        PersistentBottomNavBarItem(
          icon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: Obx(
                () => Stack(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/menus/cart.svg',
                      colorFilter: ColorFilter.mode(
                        theme.hintColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          color: MasterColor.danger,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Center(
                          child: CustomText(
                            "${controller.itemOnCart.value}",
                            fontSize: 3,
                            color: MasterColor.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          inactiveIcon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: Obx(
                () => Stack(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/menus/cart.svg',
                      colorFilter: ColorFilter.mode(
                        theme.hintColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          color: MasterColor.danger,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Center(
                          child: CustomText(
                            "${controller.itemOnCart.value}",
                            fontSize: 3,
                            color: MasterColor.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          activeColorPrimary: colors.primary,
          inactiveColorPrimary: theme.hintColor,
          title: 'Pesanan',
          textStyle: const TextStyle(fontSize: 10, height: 2),
        ),
        PersistentBottomNavBarItem(
          icon: Transform.scale(
            scale: 1.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 0), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/keluar.svg',
                colorFilter: ColorFilter.mode(
                  MasterColor.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          inactiveIcon: Transform.scale(
            scale: 1.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 0), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/keluar.svg',
                colorFilter: ColorFilter.mode(
                  MasterColor.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          title: "Keluar",
          activeColorPrimary: MasterColor.danger,
          inactiveColorPrimary: MasterColor.danger,
          textStyle: const TextStyle(fontSize: 10, height: 2),
        ),
        PersistentBottomNavBarItem(
          icon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/lend.svg',
                colorFilter: ColorFilter.mode(
                  MasterColor.success,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          inactiveIcon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/lend.svg',
                colorFilter: ColorFilter.mode(theme.hintColor, BlendMode.srcIn),
              ),
            ),
          ),
          activeColorPrimary: colors.primary,
          inactiveColorPrimary: theme.hintColor,
          title: 'Riwayat',
          textStyle: const TextStyle(fontSize: 10, height: 2),
        ),
        PersistentBottomNavBarItem(
          icon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/profile.svg',
                colorFilter: ColorFilter.mode(
                  MasterColor.success,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          inactiveIcon: Transform.scale(
            scale: 2.6, // sesuaikan
            child: Padding(
              padding: const EdgeInsets.only(top: 9), // geser turun
              child: SvgPicture.asset(
                'lib/assets/svgs/menus/profile.svg',
                colorFilter: ColorFilter.mode(theme.hintColor, BlendMode.srcIn),
              ),
            ),
          ),
          activeColorPrimary: colors.primary,
          inactiveColorPrimary: theme.hintColor,
          title: 'Profil',
          textStyle: const TextStyle(fontSize: 10, height: 2),
        ),
      ];
    }

    return PersistentTabView(
      context,
      controller: persistentTabController,
      screens: buildScreens(),
      items: navBarsItems(),
      navBarStyle: NavBarStyle.style15,
      confineToSafeArea: true,
      backgroundColor: colors.onPrimary,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarHeight: 55,
      onItemSelected: (index) async {
        if (index == 2) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Keluar Akun'),
              content: const Text('Yakin ingin keluar dari akun?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MasterColor.danger,
                    foregroundColor: MasterColor.white,
                  ),
                  child: const Text('Keluar'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await SecureStorageHelper.removeToken();
            Get.offAllNamed(Routes.MAIN_MENU);
          } else {
            persistentTabController.index = controller.currentTabIndex.value;
          }
          return;
        }
        controller.setCurrentTab(index);
      },
    );
  }
}
