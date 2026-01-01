import 'package:slims/core/constants/colors.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showConfirmDialog({
  required String title,
  required String message,
  required String labelCancel,
  required String labelConfirm,
  required VoidCallback onConfirm,
}) {
  Get.dialog(
    AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300), // Fade-in effect duration
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        titlePadding: const EdgeInsets.symmetric(horizontal: 15),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              height: 1,
              color: Colors.black,
              margin: const EdgeInsets.only(top: 10),
            )
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
        actions: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: labelCancel,
                      backgroundColor: MasterColor.info,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: CustomButton(
                      text: labelConfirm,
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ],
      ),
    ),
    barrierDismissible:
        false, // This will prevent closing dialog by tapping outside
  );
}

class FormDialogShell extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? actions;
  final IconData icon;

  const FormDialogShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.icon = Icons.edit_note,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: MasterColor.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Icon(icon, color: MasterColor.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MasterColor.dark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: MasterColor.dark_40,
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: body),
            if (actions != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
