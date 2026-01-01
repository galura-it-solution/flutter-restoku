import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppMultiSelect
///
/// Input **multiple select** (Checkbox group):
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
///   child: AppMultiSelect<String>(
///     name: "favorite_fruits",
///     label: "Favorite Fruits",
///     isFormBuilder: true,
///     options: ["Apple", "Banana", "Orange", "Grape"],
///     initialValue: ["Apple", "Orange"],
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppMultiSelect<String>(
///   name: "favorite_fruits",
///   label: "Favorite Fruits",
///   isFormBuilder: false,
///   options: ["Apple", "Banana", "Orange", "Grape"],
///   initialValue: ["Banana"],
///   onChanged: (val) => print("Selected: $val"),
/// );
/// ```
class AppMultiSelect<T> extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final List<T> options;
  final List<T>? initialValue;
  final Function(List<T>)? onChanged;
  final bool disabled;
  final List<String? Function(List<T>?)>? validators;

  const AppMultiSelect({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppMultiSelect<T>> createState() => _AppMultiSelectState<T>();
}

class _AppMultiSelectState<T> extends State<AppMultiSelect<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialValue != null
        ? List.from(widget.initialValue!)
        : [];
  }

  Widget _buildOptions(Function(List<T>)? onChangedCallback) {
    return Column(
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option);
        return CheckboxListTile(
          value: isSelected,
          title: Text(option.toString()),
          onChanged: widget.disabled
              ? null
              : (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      if (!_selectedValues.contains(option)) {
                        _selectedValues.add(option);
                      }
                    } else {
                      _selectedValues.remove(option);
                    }
                  });
                  if (!widget.isFormBuilder) {
                    onChangedCallback?.call(_selectedValues);
                  }
                },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = Column(
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
        _buildOptions(widget.onChanged),
      ],
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<List<T>>(
        name: widget.name,
        initialValue: _selectedValues,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validators != null
            ? FormBuilderValidators.compose(widget.validators!)
            : null,
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptions((val) {
                fieldState.didChange(val);
                widget.onChanged?.call(val);
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

    return field;
  }
}
