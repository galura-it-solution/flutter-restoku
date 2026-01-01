import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppInputText`
///
/// Widget input teks serbaguna:
/// - Bisa dipakai di dalam **FormBuilder** (punya validasi otomatis)
/// - Bisa dipakai secara **manual** dengan `TextEditingController`
///
/// ---
///
/// ## 📌 Cara Pakai
///
/// ### 1️⃣ Mode FormBuilder (dengan validasi)
/// ```dart
/// final _formKey = GlobalKey<FormBuilderState>();
///
/// FormBuilder(
///   key: _formKey,
///   child: Column(
///     children: [
///       AppInputText(
///         name: "email",
///         label: "Email",
///         type: "email",
///         validators: [
///           FormBuilderValidators.required(),
///           FormBuilderValidators.email(),
///         ],
///       ),
///       AppInputText(
///         name: "password",
///         label: "Password",
///         type: "password",
///         validators: [
///           FormBuilderValidators.required(),
///           FormBuilderValidators.minLength(6),
///         ],
///       ),
///     ],
///   ),
/// );
/// ```
///
/// ---
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder)
/// ```dart
/// final emailController = TextEditingController();
///
/// AppInputText(
///   name: "email",
///   label: "Email",
///   type: "email",
///   isFormBuilder: false, // ✅ harus false
///   controller: emailController,
///   onChanged: (val) {
///     print("Email berubah: $val");
///   },
/// );
///
/// print(emailController.text);
/// ```
class AppInputText extends StatefulWidget {
  /// Nama unik untuk field (wajib diisi).
  /// - Pada FormBuilder: jadi key di form state
  /// - Pada manual mode: hanya untuk konsistensi
  final String name;

  /// Label di atas input.
  final String? label;

  /// Placeholder dalam input.
  final String placeholder;

  /// Icon di sebelah kiri input.
  final Widget? leftIcon;

  /// Icon di sebelah kanan input.
  final Widget? rightIcon;

  /// Jenis input:
  /// - `"text"`
  /// - `"password"`
  /// - `"textarea"`
  /// - `"email"`
  /// - `"number"`
  final String type;

  /// Mode pemakaian:
  /// - `true` (default) → untuk FormBuilder (validasi aktif)
  /// - `false` → manual dengan controller
  final bool isFormBuilder;

  /// Controller manual (hanya dipakai jika [isFormBuilder] = false).
  final TextEditingController? controller;

  /// Callback perubahan teks (manual mode).
  final Function(String)? onChanged;

  /// Jika `true`, input disable.
  final bool disabled;
  final bool filled;
  final Color fillColor;
  final Color labelColor;
  final Color errorColor;
  final FocusNode? focusNode;

  /// Override error text manual (jarang dipakai, biasanya FormBuilder yang handle).
  final String? errorText;

  /// Daftar validator (hanya dipakai di FormBuilder mode).
  final List<String? Function(String?)>? validators;

  const AppInputText({
    super.key,
    required this.name,
    this.label,
    this.placeholder = "Enter your input",
    this.leftIcon,
    this.rightIcon,
    this.type = "text",
    this.isFormBuilder = true,
    this.controller,
    this.onChanged,
    this.disabled = false,
    this.errorText,
    this.validators,
    this.filled = false,
    this.fillColor = MasterColor.white,
    this.errorColor = MasterColor.danger,
    this.labelColor = MasterColor.black,
    this.focusNode,
  });

  @override
  State<AppInputText> createState() => _AppInputTextState();
}

class _AppInputTextState extends State<AppInputText> {
  bool _obscure = true;

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: widget.placeholder,
      prefixIcon: widget.leftIcon,
      suffixIcon: widget.type == "password"
          ? IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : widget.rightIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: MasterColor.dark_20, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: MasterColor.dark_20,
          width: 1,
        ), // abu2 normal
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: MasterColor.dark_20,
          width: 1.5,
        ), // abu2 saat fokus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: widget.errorColor,
          width: 1,
        ), // merah kalau error
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: widget.errorColor, width: 1.5),
      ),
      errorText: widget.errorText,
      enabled: !widget.disabled,
      filled: widget.filled, // ✅ enable background color
      fillColor: widget.fillColor, // ✅ background putih
      errorStyle: TextStyle(
        color: widget.errorColor, // ✅ warna error putih
        fontSize: 14,
      ),
    );
  }

  TextInputType _keyboardType() {
    switch (widget.type) {
      case "email":
        return TextInputType.emailAddress;
      case "number":
        return TextInputType.number;
      case "textarea":
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == "password";
    final maxLines = widget.type == "textarea" ? 5 : 1;

    if (widget.isFormBuilder) {
      // ✅ Dipakai di dalam FormBuilder
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.labelColor,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 6),
          FormBuilderTextField(
            focusNode: widget.focusNode,
            name: widget.name,
            obscureText: isPassword ? _obscure : false,
            keyboardType: _keyboardType(),
            maxLines: maxLines,
            decoration: _decoration(),
            validator: widget.validators != null
                ? FormBuilderValidators.compose(widget.validators!)
                : null,
            enabled: !widget.disabled,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      );
    } else {
      // ✅ Dipakai tanpa FormBuilder (manual)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.labelColor,
                fontSize: 16,
              ),
            ),
          if (widget.label != null) const SizedBox(height: 6),
          TextField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            obscureText: isPassword ? _obscure : false,
            keyboardType: _keyboardType(),
            maxLines: maxLines,
            decoration: _decoration(),
            enabled: !widget.disabled,
            onChanged: widget.onChanged,
          ),
        ],
      );
    }
  }
}
