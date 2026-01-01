import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/error_handling.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/core/utils/snackbar.dart';
import 'package:slims/infrastructure/data/restApi/auth/repository/auth.repository.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  final scrollController = ScrollController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final passwordConfirmFocus = FocusNode();

  final loading = false.obs;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    nameFocus.addListener(() {
      if (nameFocus.hasFocus) scrollToFocus(nameFocus);
    });
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) scrollToFocus(emailFocus);
    });
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) scrollToFocus(passwordFocus);
    });
    passwordConfirmFocus.addListener(() {
      if (passwordConfirmFocus.hasFocus) scrollToFocus(passwordConfirmFocus);
    });
  }

  void scrollToFocus(FocusNode focusNode, {double gap = 20}) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isDisposed) return;
      if (!scrollController.hasClients) return;

      final context = focusNode.context;
      if (context == null || !context.mounted) return;

      final object = context.findRenderObject();
      if (object is RenderBox && object.attached) {
        final yPosition = object.localToGlobal(Offset.zero).dy;
        final scrollOffset = scrollController.offset + yPosition - gap;

        scrollController.animateTo(
          scrollOffset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> submitForm() async {
    try {
      loading.value = true;
      final baseUrl = SecureStorageHelper.generateBaseUrl();
      final LoginRepository loginRepository = LoginRepository(baseUrl: baseUrl);

      if (formKey.currentState?.saveAndValidate() ?? false) {
        final values = formKey.currentState!.value;
        final name = values["name"]?.toString() ?? '';
        final email = values["email"]?.toString() ?? '';
        final password = values["password"]?.toString() ?? '';
        final passwordConfirmation =
            values["password_confirmation"]?.toString() ?? '';

        final result = await loginRepository.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );

        if (result.code >= 200 && result.code < 300) {
          SnackbarUtils.showInfo(message: 'Akun berhasil dibuat. Silakan login.');
          Get.offAllNamed(Routes.LOGIN);
        } else {
          SnackbarUtils.showInfo(message: result.message);
        }
      } else {
        SnackbarUtils.showInfo(message: 'Pastikan input terisi dengan benar');
      }
    } catch (e, s) {
      ErrorHandlingHelper.logAlertHandling(e, s, true);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    passwordConfirmFocus.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
