import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/infrastructure/navigation/routes.dart';
import 'package:slims/presentation/@shared/widgets/buttons/custom_button.dart';
import 'package:slims/presentation/@shared/widgets/form_validation/app_input_text.dart';
import 'package:slims/presentation/@shared/widgets/food_background.dart';
import 'package:slims/presentation/register/controllers/register.controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FoodBackground(
        imagePath: 'lib/assets/images/food_bg.jpg',
        overlayDark: 0.25,
        overlayLight: 0.85,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isPortrait = height > width;

            return SingleChildScrollView(
              controller: controller.scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: isPortrait ? 80 : 40,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 24),
                      FormBuilder(
                        key: controller.formKey,
                        child: Column(
                          children: [
                            AppInputText(
                              focusNode: controller.nameFocus,
                              name: 'name',
                              label: 'Nama',
                              type: 'text',
                              filled: true,
                              placeholder: 'Nama lengkap',
                              fillColor: MasterColor.white,
                              labelColor: MasterColor.white,
                              errorColor: MasterColor.white,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Nama tidak boleh kosong',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppInputText(
                              focusNode: controller.emailFocus,
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
                            AppInputText(
                              focusNode: controller.passwordFocus,
                              name: 'password',
                              label: 'Password',
                              type: 'password',
                              filled: true,
                              fillColor: MasterColor.white,
                              placeholder: 'Buat password',
                              labelColor: MasterColor.white,
                              errorColor: MasterColor.white,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Password tidak boleh kosong',
                                ),
                                FormBuilderValidators.minLength(
                                  8,
                                  errorText: 'Password minimal 8 karakter',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppInputText(
                              focusNode: controller.passwordConfirmFocus,
                              name: 'password_confirmation',
                              label: 'Konfirmasi Password',
                              type: 'password',
                              filled: true,
                              fillColor: MasterColor.white,
                              placeholder: 'Ulangi password',
                              labelColor: MasterColor.white,
                              errorColor: MasterColor.white,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Konfirmasi tidak boleh kosong',
                                ),
                                FormBuilderValidators.minLength(
                                  8,
                                  errorText: 'Konfirmasi minimal 8 karakter',
                                ),
                                (value) {
                                  final password = controller
                                      .formKey
                                      .currentState
                                      ?.fields['password']
                                      ?.value;
                                  if (value != password) {
                                    return 'Konfirmasi tidak sama';
                                  }
                                  return null;
                                },
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () => Get.back(),
                                    text: 'Kembali',
                                    height: 50,
                                    borderRadius: 10,
                                    loading: false,
                                    backgroundColor: MasterColor.dark_60,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Obx(
                                    () => CustomButton(
                                      onPressed: controller.submitForm,
                                      text: 'Daftar',
                                      height: 50,
                                      borderRadius: 10,
                                      loading: controller.loading.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Get.offNamed(Routes.LOGIN),
                              child: const Text(
                                'Sudah punya akun? Login',
                                style: TextStyle(color: MasterColor.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            color: MasterColor.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: MasterColor.white,
            size: 46,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Daftar Akun Restoku',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MasterColor.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Buat akun baru untuk mulai memesan menu favorit.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MasterColor.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
