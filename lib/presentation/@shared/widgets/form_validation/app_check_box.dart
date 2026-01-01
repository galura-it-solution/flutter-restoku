import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// 🔹 `AppCheckbox`
///
/// Widget checkbox serbaguna:
/// - Bisa dipakai di dalam **FormBuilder** (punya validasi otomatis)
/// - Bisa dipakai secara **manual** dengan `ValueNotifier` atau callback
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
///       AppCheckbox(
///         name: "accept_terms",
///         label: "Saya menyetujui syarat & ketentuan",
///         validators: [
///           FormBuilderValidators.equal(true, errorText: "Harus disetujui"),
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
/// bool agreed = false;
///
/// AppCheckbox(
///   name: "accept_terms",
///   label: "Saya menyetujui syarat & ketentuan",
///   isFormBuilder: false, // ✅ harus false
///   value: agreed,
///   onChanged: (val) {
///     print("Checkbox: $val");
///     agreed = val ?? false;
///   },
/// );
/// ```
class AppCheckbox extends StatefulWidget {
  /// Nama unik untuk field (wajib diisi).
  /// - Pada FormBuilder: jadi key di form state
  /// - Pada manual mode: hanya untuk konsistensi
  final String name;

  /// Label yang ditampilkan di sebelah kanan checkbox.
  final String label;

  /// Mode pemakaian:
  /// - `true` (default) → untuk FormBuilder (validasi aktif)
  /// - `false` → manual dengan value & onChanged
  final bool isFormBuilder;

  /// Nilai awal checkbox (dipakai hanya jika [isFormBuilder] = false).
  final bool? value;

  /// Callback perubahan nilai (manual mode).
  final ValueChanged<bool?>? onChanged;

  /// Jika `true`, checkbox disable.
  final bool disabled;

  /// Daftar validator (hanya dipakai di FormBuilder mode).
  final List<String? Function(bool?)>? validators;

  const AppCheckbox({
    super.key,
    required this.name,
    required this.label,
    this.isFormBuilder = true,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFormBuilder) {
      // ✅ Dipakai di dalam FormBuilder
      return FormBuilderCheckbox(
        name: widget.name,
        title: Text(widget.label),
        enabled: !widget.disabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
      );
    } else {
      // ✅ Dipakai tanpa FormBuilder (manual)
      return CheckboxListTile(
        value: widget.value ?? false,
        title: Text(widget.label),
        onChanged: widget.disabled ? null : widget.onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }
}
