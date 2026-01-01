import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppSliderInput
///
/// Input slider:
/// - Bisa dipakai di dalam **FormBuilder**
/// - Bisa dipakai secara manual (tanpa FormBuilder)
///
/// ---
///
/// 📌 Contoh penggunaan:
///
/// ### 1️⃣ Mode FormBuilder
/// ```dart
/// FormBuilder(
///   key: _formKey,
///   child: AppSliderInput(
///     name: "rating",
///     label: "Rating",
///     isFormBuilder: true,
///     min: 0,
///     max: 10,
///     divisions: 10,
///     initialValue: 5,
///     validators: [FormBuilderValidators.min(1)],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppSliderInput(
///   name: "rating",
///   label: "Rating",
///   isFormBuilder: false,
///   min: 0,
///   max: 100,
///   divisions: 20,
///   initialValue: 50,
///   onChanged: (val) => print("Slider value: $val"),
/// );
/// ```
class AppSliderInput extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final double min;
  final double max;
  final int? divisions;
  final double? initialValue;
  final bool disabled;
  final Function(double)? onChanged;
  final List<String? Function(double?)>? validators;

  const AppSliderInput({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    required this.min,
    required this.max,
    this.divisions,
    this.initialValue,
    this.disabled = false,
    this.onChanged,
    this.validators,
  });

  @override
  State<AppSliderInput> createState() => _AppSliderInputState();
}

class _AppSliderInputState extends State<AppSliderInput> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? widget.min;
  }

  @override
  Widget build(BuildContext context) {
    final slider = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        Slider(
          value: _value,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          label: _value.toStringAsFixed(0),
          onChanged: widget.disabled
              ? null
              : (val) {
                  setState(() => _value = val);
                  if (!widget.isFormBuilder) {
                    widget.onChanged?.call(val);
                  }
                },
        ),
      ],
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<double>(
        name: widget.name,
        initialValue: widget.initialValue ?? widget.min,
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
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              Slider(
                value: fieldState.value ?? widget.min,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: (fieldState.value ?? widget.min).toStringAsFixed(0),
                onChanged: widget.disabled
                    ? null
                    : (val) {
                        fieldState.didChange(val);
                        setState(() => _value = val);
                        widget.onChanged?.call(val);
                      },
              ),
              if (fieldState.errorText != null)
                Text(
                  fieldState.errorText!,
                  style: const TextStyle(color: MasterColor.danger),
                ),
            ],
          );
        },
      );
    }

    return slider;
  }
}
