import 'package:get/get.dart';

import '../../../../presentation/order_history/controllers/order_history.controller.dart';

class OrderHistoryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
  }
}
