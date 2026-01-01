import 'dart:async';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/utils/error_handling.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/core/utils/snackbar.dart';
import 'package:slims/infrastructure/data/restApi/auth/repository/auth.repository.dart';
import 'package:slims/infrastructure/navigation/routes.dart';

class LoginController extends GetxController {
  final scrollController = ScrollController();
  final loading = false.obs;
  final awaitingOtp = false.obs;
  final otpCountdown = 0.obs;
  final otpError = ''.obs;
  Timer? _otpTimer;
  bool _isDisposed = false;
  String _cachedEmail = '';
  String _cachedPassword = '';

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

  void submitForm(GlobalKey<FormBuilderState> formKey) async {
    try {
      loading.value = true;
      final baseUrl = SecureStorageHelper.generateBaseUrl();
      final LoginRepository loginRepository = LoginRepository(baseUrl: baseUrl);

      if (formKey.currentState?.saveAndValidate() ?? false) {
        final values = formKey.currentState!.value;
        final email = values["email"]?.toString() ?? '';
        final password = values["password"]?.toString() ?? '';
        final otp = values["otp"]?.toString() ?? '';
        final emailForOtp = awaitingOtp.value ? _cachedEmail : email;

        if (!awaitingOtp.value) {
          final result = await loginRepository.login(email, password);
          if (result.code >= 200 && result.code < 300) {
            await SecureStorageHelper.saveUser(result.data['user']);
            awaitingOtp.value = true;
            _cachedEmail = email;
            _cachedPassword = password;
            _startOtpCountdown();
            otpError.value = '';
            SnackbarUtils.showInfo(
              message: 'OTP telah dikirim ke email kamu.',
            );
          } else {
            SnackbarUtils.showInfo(message: result.message);
          }
          return;
        }

        final result = await loginRepository.verifyOtp(emailForOtp, otp);
        if (result.code >= 200 && result.code < 300) {
          final token = result.data['token']?.toString() ?? '';
          await SecureStorageHelper.saveAccessToken(token);
          final isSellerRole = await SecureStorageHelper.isSeller();
          Get.offAllNamed(isSellerRole ? Routes.SELLER_HOME : Routes.HOME);
        } else {
          otpError.value =
              result.message.isEmpty ? 'OTP tidak valid.' : result.message;
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

  Future<void> resendOtp() async {
    if (otpCountdown.value > 0 || _cachedEmail.isEmpty) return;
    loading.value = true;
    try {
      final baseUrl = SecureStorageHelper.generateBaseUrl();
      final LoginRepository loginRepository = LoginRepository(baseUrl: baseUrl);
      final result = await loginRepository.login(_cachedEmail, _cachedPassword);
      if (result.code >= 200 && result.code < 300) {
        _startOtpCountdown();
        otpError.value = '';
        SnackbarUtils.showInfo(message: 'OTP baru sudah dikirim.');
      } else {
        SnackbarUtils.showInfo(message: result.message);
      }
    } finally {
      loading.value = false;
    }
  }

  void _startOtpCountdown({int seconds = 60}) {
    _otpTimer?.cancel();
    otpCountdown.value = seconds;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCountdown.value <= 1) {
        otpCountdown.value = 0;
        timer.cancel();
        return;
      }
      otpCountdown.value = otpCountdown.value - 1;
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    scrollController.dispose();
    _otpTimer?.cancel();
    super.onClose();
  }
}
