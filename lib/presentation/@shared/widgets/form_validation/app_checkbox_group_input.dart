import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppCheckboxGroupInput
///
/// Input checkbox group:
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
///   child: AppCheckboxGroupInput(
///     name: "hobbies",
///     label: "Pilih Hobi",
///     isFormBuilder: true,
///     options: [
///       {"label": "Membaca", "value": "reading"},
///       {"label": "Olahraga", "value": "sport"},
///       {"label": "Musik", "value": "music"},
///     ],
///     initialValue: ["reading"],
///     validators: [FormBuilderValidators.minLength(1)],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppCheckboxGroupInput(
///   name: "hobbies",
///   label: "Pilih Hobi",
///   isFormBuilder: false,
///   options: [
///     {"label": "Membaca", "value": "reading"},
///     {"label": "Olahraga", "value": "sport"},
///     {"label": "Musik", "value": "music"},
///   ],
///   initialValue: ["sport"],
///   onChanged: (val) => print("Selected: $val"),
/// );
/// ```
class AppCheckboxGroupInput extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final List<Map<String, dynamic>> options; // {label, value}
  final List<String>? initialValue;
  final bool disabled;
  final Function(List<String>)? onChanged;
  final List<String? Function(List<String>?)>? validators;

  const AppCheckboxGroupInput({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    required this.options,
    this.initialValue,
    this.disabled = false,
    this.onChanged,
    this.validators,
  });

  @override
  State<AppCheckboxGroupInput> createState() => _AppCheckboxGroupInputState();
}

class _AppCheckboxGroupInputState extends State<AppCheckboxGroupInput> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialValue ?? [];
  }

  void _handleChanged(String value, bool checked) {
    if (widget.disabled) return;

    setState(() {
      if (checked) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });

    if (!widget.isFormBuilder) {
      widget.onChanged?.call(_selectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkboxes = Column(
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
        ...widget.options.map((opt) {
          final label = opt["label"] as String;
          final value = opt["value"] as String;
          final isChecked = _selectedValues.contains(value);

          return CheckboxListTile(
            title: Text(label),
            value: isChecked,
            onChanged: widget.disabled
                ? null
                : (val) => _handleChanged(value, val ?? false),
          );
        }),
      ],
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<List<String>>(
        name: widget.name,
        initialValue: widget.initialValue ?? [],
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...widget.options.map((opt) {
                final label = opt["label"] as String;
                final value = opt["value"] as String;
                final isChecked = fieldState.value?.contains(value) ?? false;

                return CheckboxListTile(
                  title: Text(label),
                  value: isChecked,
                  onChanged: widget.disabled
                      ? null
                      : (val) {
                          final newValues = List<String>.from(
                            fieldState.value ?? [],
                          );
                          if (val == true) {
                            newValues.add(value);
                          } else {
                            newValues.remove(value);
                          }
                          fieldState.didChange(newValues);
                          _handleChanged(value, val ?? false);
                        },
                );
              }),
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

    return checkboxes;
  }
}
