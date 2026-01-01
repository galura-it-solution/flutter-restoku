import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:slims/presentation/@shared/widgets/modals/modal_empty_content.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';

enum TypeAlert { success, info, warning, danger, key, commingsoon }

class ModalNotificationWidget extends StatelessWidget {
  const ModalNotificationWidget({
    super.key,
    required this.title,
    required this.descriptions,
    required this.typeAlert,
    required this.textBtn,
    required this.onPress,
    required this.loading,
  });
  final String title, descriptions, textBtn;
  final String typeAlert;
  final Function onPress;
  final RxBool loading;

  @override
  Widget build(BuildContext context) {
    var imagePath = '';
    switch (typeAlert) {
      case 'success':
        imagePath += 'lib/assets/images/modal/success.webp';
        break;
      case 'info':
        imagePath += 'lib/assets/images/modal/information.webp';
        break;
      case 'warning':
        imagePath += 'lib/assets/images/modal/warning.webp';
        break;
      case 'danger':
        imagePath += 'lib/assets/images/modal/danger.webp';
        break;
      case 'key':
        imagePath += 'lib/assets/images/modal/key.webp';
        break;
      case 'commingsoon':
        imagePath += 'lib/assets/images/modal/commingsoon.webp';
        break;
      default:
    }

    return ModalEmptyContent(
      width: Get.width - 30,
      canScrolling: true,
      child: Column(
        mainAxisSize: MainAxisSize.min, // ⬅️ penting biar shrink-wrap
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.close),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.width * .5,
            ),
          ),
          CustomText.title(title),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Text(descriptions, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text: loading.value == true ? "Loading..." : textBtn,
                      onPressed: loading.value == true
                          ? () {}
                          : () => onPress(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
