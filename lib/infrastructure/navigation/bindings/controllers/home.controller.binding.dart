import 'package:get/get.dart';
import 'package:slims/presentation/keranjang/controllers/keranjang.controller.dart';
import 'package:slims/presentation/keranjang/controllers/ongoing_orders.controller.dart';
import 'package:slims/presentation/account/controllers/account.controller.dart';
import 'package:slims/presentation/order_history/controllers/order_history.controller.dart';
import 'package:slims/presentation/notifications/controllers/notification.controller.dart';
import '../../../../presentation/home/controllers/home.controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put(KeranjangController(), permanent: true);
    Get.lazyPut<OngoingOrdersController>(() => OngoingOrdersController());
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
