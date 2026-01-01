import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'middlewares/seller_guard.middleware.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.SPLASH_SCREEN,
      page: () => const SplashScreenScreen(),
      binding: SplashScreenControllerBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterControllerBinding(),
    ),
    GetPage(
      name: Routes.ACCOUNT,
      page: () => const AccountScreen(),
      binding: AccountControllerBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.MAIN_MENU,
      page: () => const MainMenuScreen(),
      binding: MainMenuControllerBinding(),
    ),
    GetPage(
      name: Routes.SELLER_HOME,
      page: () => const SellerHomeScreen(),
      binding: SellerHomeControllerBinding(),
      middlewares: [SellerGuardMiddleware()],
    ),
    GetPage(
      name: Routes.BERANDA,
      page: () => const BerandaScreen(),
      binding: BerandaControllerBinding(),
    ),
    GetPage(
      name: Routes.KERANJANG,
      page: () => const KeranjangScreen(),
      binding: KeranjangControllerBinding(),
    ),
    GetPage(
      name: Routes.ORDER_HISTORY,
      page: () => const OrderHistoryScreen(),
      binding: OrderHistoryControllerBinding(),
    ),
    GetPage(
      name: Routes.ORDER_DETAIL,
      page: () => const OrderDetailScreen(),
      binding: OrderDetailControllerBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_MENU,
      page: () => const DetailMenuScreen(),
      binding: DetailMenuControllerBinding(),
    ),
    GetPage(
      name: Routes.TABLE_SCAN,
      page: () => const TableScanScreen(),
    ),
  ];
}
