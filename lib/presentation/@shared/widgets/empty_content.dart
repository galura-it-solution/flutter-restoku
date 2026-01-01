import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:slims/presentation/@shared/widgets/text/custom_text.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    super.key,
    required this.onPressed,
    required this.loading,
  });
  final void Function()? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInImage(
            placeholder: const AssetImage('lib/assets/images/placeholder.png'),
            image: const AssetImage(
              'lib/assets/images/empty-state/no-data.png',
            ),
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 100),
          ),
          SizedBox(height: 10),
          CustomText("Halaman Kosong"),
          SizedBox(height: 10),
          loading
              ? CustomText("Loading...")
              : CustomButton(
                  onPressed: onPressed,
                  borderRadius: 60,
                  padding: EdgeInsets.all(0),
                  height: 60,
                  width: 60,
                  child: Center(
                    child: Icon(Icons.refresh, color: Colors.white, size: 40),
                  ),
                ),
        ],
      ),
    );
  }
}
