import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:slims/presentation/@shared/widgets/form_validation/app_input_text.dart';
import 'package:slims/presentation/login/controllers/login.controller.dart';

class FormLogin extends StatefulWidget {
  const FormLogin({super.key, required this.controller, required this.width});

  final LoginController controller;
  final double width;

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _otpFocus;

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _otpFocus = FocusNode();

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        widget.controller.scrollToFocus(_emailFocus);
      }
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        widget.controller.scrollToFocus(_passwordFocus);
      }
    });
    _otpFocus.addListener(() {
      if (_otpFocus.hasFocus) {
        widget.controller.scrollToFocus(_otpFocus);
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          Obx(
            () => widget.controller.awaitingOtp.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      AppInputText(
                        focusNode: _emailFocus,
                        name: 'email',
                        label: 'Email',
                        type: 'email',
                        filled: true,
                        placeholder: 'Masukkan email',
                        fillColor: MasterColor.white,
                        labelColor: MasterColor.white,
                        errorColor: MasterColor.white,
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Email tidak boleh kosong',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'Format email tidak valid',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
          ),
          Obx(
            () => widget.controller.awaitingOtp.value
                ? const SizedBox.shrink()
                : AppInputText(
                    focusNode: _passwordFocus,
                    name: 'password',
                    label: 'Password',
                    type: 'password',
                    filled: true,
                    fillColor: MasterColor.white,
                    placeholder: 'Masukkan password',
                    labelColor: MasterColor.white,
                    errorColor: MasterColor.white,
                    validators: [
                      FormBuilderValidators.required(
                        errorText: 'Password tidak boleh kosong',
                      ),
                    ],
                  ),
          ),
          Obx(
            () => widget.controller.awaitingOtp.value
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      AppInputText(
                        focusNode: _otpFocus,
                        name: 'otp',
                        label: 'Kode OTP',
                        type: 'text',
                        filled: true,
                        fillColor: MasterColor.white,
                        placeholder: 'Masukkan OTP',
                        labelColor: MasterColor.white,
                        errorColor: MasterColor.white,
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'OTP tidak boleh kosong',
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: 'OTP minimal 6 digit',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () {
                          final seconds = widget.controller.otpCountdown.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                seconds > 0
                                    ? 'Kirim ulang OTP dalam $seconds detik'
                                    : 'Tidak menerima OTP?',
                                style: const TextStyle(
                                  color: MasterColor.white,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: seconds > 0
                                    ? null
                                    : widget.controller.resendOtp,
                                child: const Text('Kirim Ulang'),
                              ),
                            ],
                          );
                        },
                      ),
                      Obx(
                        () => widget.controller.otpError.value.isEmpty
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.controller.otpError.value,
                                  style: const TextStyle(
                                    color: MasterColor.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  text: 'Kembali',
                  height: 50,
                  borderRadius: 10,
                  loading: false,
                  backgroundColor: MasterColor.danger_100,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Obx(
                  () => CustomButton(
                    onPressed: () {
                      widget.controller.submitForm(_formKey);
                    },
                    text: widget.controller.awaitingOtp.value
                        ? 'Verifikasi'
                        : 'Kirim OTP',
                    height: 50,
                    borderRadius: 10,
                    loading: widget.controller.loading.value,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.toNamed(Routes.REGISTER),
            child: const Text(
              'Belum punya akun? Daftar',
              style: TextStyle(color: MasterColor.white),
            ),
          ),
        ],
      ),
    );
  }
}
