import 'package:get/get.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';

class DetailMenuController extends GetxController {
  final menu = Rxn<MenuModel>();

  @override
  void onInit() {
    menu.value = Get.arguments as MenuModel?;
    super.onInit();
  }
}
