import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// 🔹 `AppSelect`
///
/// Widget dropdown / select serbaguna:
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
///       AppSelect(
///         name: "gender",
///         label: "Jenis Kelamin",
///         options: ["Pria", "Wanita"],
///         validators: [FormBuilderValidators.required()],
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
/// String? selectedGender;
///
/// AppSelect(
///   name: "gender",
///   label: "Jenis Kelamin",
///   options: ["Pria", "Wanita"],
///   isFormBuilder: false, // ✅ harus false
///   value: selectedGender,
///   onChanged: (val) {
///     print("Gender dipilih: $val");
///     selectedGender = val;
///   },
/// );
/// ```
class AppSelect extends StatefulWidget {
  /// Nama unik untuk field (wajib diisi).
  /// - Pada FormBuilder: jadi key di form state
  /// - Pada manual mode: hanya untuk konsistensi
  final String name;

  /// Label ditampilkan di atas dropdown.
  final String label;

  /// Daftar pilihan.
  final List<String> options;

  /// Mode pemakaian:
  /// - `true` (default) → untuk FormBuilder (validasi aktif)
  /// - `false` → manual dengan value & onChanged
  final bool isFormBuilder;

  /// Nilai awal / terpilih (manual mode).
  final String? value;

  /// Callback perubahan nilai (manual mode).
  final ValueChanged<String?>? onChanged;

  /// Jika `true`, dropdown disable.
  final bool disabled;

  /// Daftar validator (hanya dipakai di FormBuilder mode).
  final List<String? Function(String?)>? validators;

  const AppSelect({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    this.isFormBuilder = true,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFormBuilder) {
      // ✅ Dipakai di dalam FormBuilder
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FormBuilderDropdown<String>(
            name: widget.name,
            items: widget.options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            enabled: !widget.disabled,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validators != null
                ? FormBuilderValidators.compose(widget.validators!)
                : null,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
    } else {
      // ✅ Dipakai tanpa FormBuilder (manual)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue:
                widget.value, // ❌ ganti 'value' menjadi 'initialValue'
            onChanged: widget.disabled ? null : widget.onChanged,
            items: widget.options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
    }
  }
}
