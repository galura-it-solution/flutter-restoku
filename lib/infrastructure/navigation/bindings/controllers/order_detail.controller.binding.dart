import 'package:get/get.dart';

import '../../../../presentation/order_detail/controllers/order_detail.controller.dart';

class OrderDetailControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDetailController>(() => OrderDetailController());
  }
}
