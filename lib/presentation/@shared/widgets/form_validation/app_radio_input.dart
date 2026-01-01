// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// 🔹 `AppRadioInput`
///
/// Widget input **radio**:
/// - ✅ Bisa dipakai di dalam **FormBuilder** (validasi otomatis)
/// - ✅ Bisa dipakai manual dengan `onChanged`
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
///   child: AppRadioInput<String>(
///     name: "gender",
///     label: "Gender",
///     isFormBuilder: true,
///     options: ["Male", "Female", "Other"],
///     initialValue: "Male",
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppRadioInput<String>(
///   name: "gender",
///   label: "Gender",
///   isFormBuilder: false,
///   options: ["Male", "Female", "Other"],
///   initialValue: "Female",
///   onChanged: (val) {
///     print("Selected: $val");
///   },
/// );
/// ```
class AppRadioInput<T> extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final bool disabled;
  final List<String? Function(T?)>? validators;
  final List<T> options;
  final Axis direction; // horizontal atau vertical

  const AppRadioInput({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    this.initialValue,
    this.onChanged,
    this.disabled = false,
    this.validators,
    required this.options,
    this.direction = Axis.vertical,
  });

  @override
  State<AppRadioInput<T>> createState() => _AppRadioInputState<T>();
}

class _AppRadioInputState<T> extends State<AppRadioInput<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  /// 🔹 Mode Manual: pakai `RadioListTile` (masih aman di Flutter stable)
  Widget _buildManualRadioGroup() {
    return Flex(
      direction: widget.direction,
      children: widget.options.map((option) {
        return Expanded(
          child: RadioListTile<T>(
            value: option,
            groupValue: _selectedValue,
            title: Text(option.toString()),
            onChanged: widget.disabled
                ? null
                : (val) {
                    setState(() => _selectedValue = val);
                    if (!widget.isFormBuilder) widget.onChanged?.call(val);
                  },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFormBuilder) {
      return FormBuilderRadioGroup<T>(
        name: widget.name,
        initialValue: widget.initialValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
        decoration: InputDecoration(
          labelText: widget.label,
          border: InputBorder.none,
        ),
        options: widget.options
            .map((option) => FormBuilderFieldOption<T>(
                  value: option,
                  child: Text(option.toString()),
                ))
            .toList(),
        orientation: widget.direction == Axis.horizontal
            ? OptionsOrientation.horizontal
            : OptionsOrientation.vertical,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _buildManualRadioGroup(),
      ],
    );
  }
}
