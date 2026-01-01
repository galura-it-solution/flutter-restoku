import 'package:get/get.dart';

import '../../../../presentation/keranjang/controllers/keranjang.controller.dart';

class KeranjangControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeranjangController>(
      () => KeranjangController(),
    );
  }
}
