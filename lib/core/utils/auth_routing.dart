import 'package:slims/core/utils/shared_preference.dart';
import 'package:slims/infrastructure/data/restApi/auth/model/response_login.model.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';

void authRouting({required ResponseLoginModel data}) async {
  await SharedPrefsHelper.saveString('token', data.data.token);
  if (data.data.token.isNotEmpty) {
    Get.offAllNamed(Routes.HOME);
  } else {
    Get.offAllNamed(Routes.MAIN_MENU);
  }
}
