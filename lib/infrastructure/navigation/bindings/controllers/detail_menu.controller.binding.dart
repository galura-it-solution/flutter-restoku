import 'package:get/get.dart';

import '../../../../presentation/detail_menu/controllers/detail_menu.controller.dart';

class DetailMenuControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailMenuController>(
      () => DetailMenuController(),
    );
  }
}
