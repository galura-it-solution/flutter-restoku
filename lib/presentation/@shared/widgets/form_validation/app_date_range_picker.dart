import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppDateRangePicker`
///
/// Widget input untuk memilih rentang tanggal (start & end):
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
///   child: AppDateRangePicker(
///     name: "event_range",
///     label: "Event Date Range",
///     isFormBuilder: true,
///     initialValue: DateTimeRange(
///       start: DateTime.now(),
///       end: DateTime.now().add(Duration(days: 3)),
///     ),
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder, dengan initial value)
/// ```dart
/// final rangeController = TextEditingController();
///
/// AppDateRangePicker(
///   name: "event_range",
///   label: "Event Date Range",
///   isFormBuilder: false,
///   controller: rangeController,
///   initialValue: DateTimeRange(
///     start: DateTime.now(),
///     end: DateTime.now().add(Duration(days: 3)),
///   ),
///   onChanged: (val) {
///     print("Selected range: $val");
///   },
/// );
/// ```
class AppDateRangePicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final DateTimeRange? initialValue;
  final Function(DateTimeRange?)? onChanged;
  final bool disabled;
  final List<String? Function(DateTimeRange?)>? validators;

  const AppDateRangePicker({
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
  State<AppDateRangePicker> createState() => _AppDateRangePickerState();
}

class _AppDateRangePickerState extends State<AppDateRangePicker> {
  late final TextEditingController _internalController;
  DateTimeRange? _selectedRange;

  TextEditingController get _controller => widget.isFormBuilder
      ? _internalController
      : (widget.controller ?? _internalController);

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialValue;
    _internalController = TextEditingController(
      text: widget.initialValue != null
          ? _formatRange(widget.initialValue!)
          : '',
    );
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = _formatRange(widget.initialValue!);
    }
  }

  String _formatRange(DateTimeRange range) {
    return "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')} "
        "to ${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDateRange() async {
    final initialStart = _selectedRange?.start ?? DateTime.now();
    final initialEnd =
        _selectedRange?.end ?? DateTime.now().add(const Duration(days: 1));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (picked == null) return;

    setState(() {
      _selectedRange = picked;
      _controller.text = _formatRange(picked);
    });

    if (!widget.isFormBuilder) widget.onChanged?.call(picked);
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Date Range",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.date_range),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickDateRange,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
        ),
      ),
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<DateTimeRange>(
        name: widget.name,
        initialValue: _selectedRange,
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
