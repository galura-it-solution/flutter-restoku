import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppSwitchInput
///
/// Input switch yang fleksibel:
/// - Bisa dipakai di dalam **FormBuilder**
/// - Bisa dipakai secara manual dengan `onChanged`
///
/// 📌 Contoh penggunaan:
///
/// ### 1️⃣ Mode FormBuilder
/// ```dart
/// FormBuilder(
///   key: _formKey,
///   child: AppSwitchInput(
///     name: "is_active",
///     label: "Aktif?",
///     isFormBuilder: true,
///     initialValue: true,
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppSwitchInput(
///   name: "is_active",
///   label: "Aktif?",
///   isFormBuilder: false,
///   initialValue: false,
///   onChanged: (val) => print("Switch: $val"),
/// );
/// ```
class AppSwitchInput extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final bool initialValue;
  final bool disabled;
  final Function(bool)? onChanged;
  final List<String? Function(bool?)>? validators;

  const AppSwitchInput({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    this.initialValue = false,
    this.disabled = false,
    this.onChanged,
    this.validators,
  });

  @override
  State<AppSwitchInput> createState() => _AppSwitchInputState();
}

class _AppSwitchInputState extends State<AppSwitchInput> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _handleChanged(bool val) {
    if (widget.disabled) return;
    setState(() => _value = val);
    if (!widget.isFormBuilder) {
      widget.onChanged?.call(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    final switchWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.label != null)
          Expanded(
            child: Text(
              widget.label!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        Switch(
          value: _value,
          onChanged: widget.disabled ? null : _handleChanged,
        ),
      ],
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<bool>(
        name: widget.name,
        initialValue: widget.initialValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.label != null)
                    Expanded(
                      child: Text(
                        widget.label!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Switch(
                    value: fieldState.value ?? widget.initialValue,
                    onChanged: widget.disabled
                        ? null
                        : (val) {
                            fieldState.didChange(val);
                            _handleChanged(val);
                          },
                  ),
                ],
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

    return switchWidget;
  }
}
