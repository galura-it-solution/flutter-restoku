import 'package:get/get.dart';

import '../../../../presentation/main_menu/controllers/main_menu.controller.dart';

class MainMenuControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainMenuController>(
      () => MainMenuController(),
    );
  }
}
