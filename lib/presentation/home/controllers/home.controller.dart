import 'package:flutter/widgets.dart' show PageController;
import 'package:get/get.dart';
import 'package:slims/presentation/keranjang/controllers/keranjang.controller.dart';

class HomeController extends GetxController {
  late PageController pageViewController;
  int activePageIndex = 0;
  final itemOnCart = 0.obs;
  final currentTabIndex = 0.obs;

  void onPageChanged(int index) {
    pageViewController.jumpToPage(index);
    activePageIndex = index;
    update();
  }

  void setCurrentTab(int index) {
    currentTabIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    setCountItemCart();
    pageViewController = PageController(initialPage: activePageIndex);
  }

  void setCountItemCart() async {
    KeranjangController keranjangController = Get.find();
    itemOnCart.value = keranjangController.listCart.length;
  }

  @override
  void onClose() {
    super.onClose();
    pageViewController.dispose();
  }
}
