import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppDatePicker`
///
/// Widget date picker:
/// - Bisa dipakai di dalam **FormBuilder** (dengan validasi)
/// - Bisa dipakai secara **manual** dengan `TextEditingController`
///
/// ---
///
/// ## 📌 Cara Pakai
///
/// ### 1️⃣ Mode FormBuilder (dengan validasi dan initial value)
/// ```dart
/// final _formKey = GlobalKey<FormBuilderState>();
///
/// FormBuilder(
///   key: _formKey,
///   child: AppDatePicker(
///     name: "birth_date",
///     label: "Birth Date",
///     isFormBuilder: true,
///     initialValue: DateTime(1990, 1, 1),
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder, dengan initial value)
/// ```dart
/// final dateController = TextEditingController();
///
/// AppDatePicker(
///   name: "birth_date",
///   label: "Birth Date",
///   isFormBuilder: false,
///   controller: dateController,
///   initialValue: DateTime(1990, 1, 1),
///   onChanged: (val) {
///     print("Selected: $val");
///   },
/// );
/// ```
class AppDatePicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final DateTime? initialValue;
  final Function(DateTime?)? onChanged;
  final bool disabled;
  final List<String? Function(DateTime?)>? validators;

  const AppDatePicker({
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
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late final TextEditingController _internalController;
  DateTime? _selectedDate;

  TextEditingController get _controller => widget.isFormBuilder
      ? _internalController
      : (widget.controller ?? _internalController);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
    _internalController = TextEditingController(
      text: widget.initialValue != null
          ? _formatDate(widget.initialValue!)
          : '',
    );
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = _formatDate(widget.initialValue!);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      if (!widget.isFormBuilder) widget.onChanged?.call(picked);
    }
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Date",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.calendar_today),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickDate,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
        ),
      ),
    );

    // Jika mode FormBuilder
    if (widget.isFormBuilder) {
      return FormBuilderField<DateTime>(
        name: widget.name,
        initialValue: _selectedDate,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              field,
              if (fieldState.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fieldState.errorText!,
                    style: const TextStyle(color: MasterColor.danger),
                  ),
                ),
            ],
          );
        },
      );
    }

    // Mode manual
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        field,
      ],
    );
  }
}
