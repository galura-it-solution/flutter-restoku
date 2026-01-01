import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppRangeSliderInput
///
/// Input **Range Slider** (min - max):
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
///   child: AppRangeSliderInput(
///     name: "price_range",
///     label: "Price Range",
///     isFormBuilder: true,
///     min: 0,
///     max: 100,
///     divisions: 20,
///     initialValue: const RangeValues(20, 80),
///     validators: [
///       (val) {
///         if (val == null) return "Required";
///         if (val.end - val.start < 10) {
///           return "Range must be at least 10";
///         }
///         return null;
///       }
///     ],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppRangeSliderInput(
///   name: "price_range",
///   label: "Price Range",
///   isFormBuilder: false,
///   min: 0,
///   max: 100,
///   divisions: 20,
///   initialValue: const RangeValues(10, 50),
///   onChanged: (val) => print("Selected Range: ${val.start} - ${val.end}"),
/// );
/// ```
class AppRangeSliderInput extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final double min;
  final double max;
  final int? divisions;
  final RangeValues? initialValue;
  final bool disabled;
  final Function(RangeValues)? onChanged;
  final List<String? Function(RangeValues?)>? validators;

  const AppRangeSliderInput({
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
  State<AppRangeSliderInput> createState() => _AppRangeSliderInputState();
}

class _AppRangeSliderInputState extends State<AppRangeSliderInput> {
  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = widget.initialValue ?? RangeValues(widget.min, widget.max);
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
        RangeSlider(
          values: _values,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          labels: RangeLabels(
            _values.start.toStringAsFixed(0),
            _values.end.toStringAsFixed(0),
          ),
          onChanged: widget.disabled
              ? null
              : (val) {
                  setState(() => _values = val);
                  if (!widget.isFormBuilder) {
                    widget.onChanged?.call(val);
                  }
                },
        ),
      ],
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<RangeValues>(
        name: widget.name,
        initialValue:
            widget.initialValue ?? RangeValues(widget.min, widget.max),
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
              RangeSlider(
                values: fieldState.value ?? RangeValues(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                labels: RangeLabels(
                  (fieldState.value ?? RangeValues(widget.min, widget.max))
                      .start
                      .toStringAsFixed(0),
                  (fieldState.value ?? RangeValues(widget.min, widget.max)).end
                      .toStringAsFixed(0),
                ),
                onChanged: widget.disabled
                    ? null
                    : (val) {
                        fieldState.didChange(val);
                        setState(() => _values = val);
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
