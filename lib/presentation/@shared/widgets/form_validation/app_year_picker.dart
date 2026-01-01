import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppYearPicker`
///
/// Widget untuk memilih **tahun** saja:
/// - Tidak menampilkan bulan atau tanggal
/// - Bisa dipakai di **FormBuilder** atau manual
/// - Mendukung **initialValue** dan **onChanged**
///
/// ---
///
/// ## 📌 Cara Pakai
///
/// ### 1️⃣ Mode FormBuilder
/// ```dart
/// final _formKey = GlobalKey<FormBuilderState>();
///
/// FormBuilder(
///   key: _formKey,
///   child: AppYearPicker(
///     name: "tahun",
///     label: "Tahun",
///     isFormBuilder: true,
///     initialValue: 2025,
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// final controller = TextEditingController();
///
/// AppYearPicker(
///   name: "tahun",
///   label: "Tahun",
///   isFormBuilder: false,
///   controller: controller,
///   initialValue: 2025,
///   onChanged: (val) {
///     print("Selected year: $val");
///   },
/// );
/// ```
class AppYearPicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final int? initialValue;
  final Function(int?)? onChanged;
  final bool disabled;
  final List<String? Function(int?)>? validators;

  const AppYearPicker({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppYearPicker> createState() => _AppYearPickerState();
}

class _AppYearPickerState extends State<AppYearPicker> {
  late final TextEditingController _internalController;
  int? _selectedYear;

  TextEditingController get _controller => widget.isFormBuilder
      ? _internalController
      : (widget.controller ?? _internalController);

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialValue;
    _internalController = TextEditingController(
        text:
            widget.initialValue != null ? widget.initialValue.toString() : '');
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = widget.initialValue.toString();
    }
  }

  Future<void> _pickYear() async {
    final now = DateTime.now();
    final initialDate = DateTime(_selectedYear ?? now.year);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedYear = picked.year;
      _controller.text = picked.year.toString();
    });

    if (!widget.isFormBuilder) widget.onChanged?.call(_selectedYear);
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Year",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.calendar_today),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickYear,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
        ),
      ),
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<int>(
        name: widget.name,
        initialValue: _selectedYear,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field,
              if (fieldState.errorText != null)
                Text(fieldState.errorText!,
                    style: const TextStyle(color: MasterColor.danger)),
            ],
          );
        },
      );
    }

    return field;
  }
}
