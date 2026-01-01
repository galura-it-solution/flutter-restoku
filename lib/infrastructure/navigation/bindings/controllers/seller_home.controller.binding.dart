import 'package:get/get.dart';

import '../../../../presentation/account/controllers/account.controller.dart';

class SellerHomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
