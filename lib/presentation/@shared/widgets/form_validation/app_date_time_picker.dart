import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppDateTimePicker`
///
/// Widget input untuk tanggal + jam (DateTime):
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
///   child: AppDateTimePicker(
///     name: "event_datetime",
///     label: "Event DateTime",
///     isFormBuilder: true,
///     initialValue: DateTime.now(),
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder, dengan initial value)
/// ```dart
/// final datetimeController = TextEditingController();
///
/// AppDateTimePicker(
///   name: "event_datetime",
///   label: "Event DateTime",
///   isFormBuilder: false,
///   controller: datetimeController,
///   initialValue: DateTime.now(),
///   onChanged: (val) {
///     print("Selected: $val");
///   },
/// );
/// ```
class AppDateTimePicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final DateTime? initialValue;
  final Function(DateTime?)? onChanged;
  final bool disabled;
  final List<String? Function(DateTime?)>? validators;

  const AppDateTimePicker({
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
  State<AppDateTimePicker> createState() => _AppDateTimePickerState();
}

class _AppDateTimePickerState extends State<AppDateTimePicker> {
  late final TextEditingController _internalController;
  DateTime? _selectedDateTime;

  TextEditingController get _controller => widget.isFormBuilder
      ? _internalController
      : (widget.controller ?? _internalController);

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialValue;
    _internalController = TextEditingController(
      text: widget.initialValue != null
          ? _formatDateTime(widget.initialValue!)
          : '',
    );
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = _formatDateTime(widget.initialValue!);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDateTime() async {
    DateTime initialDate = _selectedDateTime ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay(
              hour: _selectedDateTime!.hour,
              minute: _selectedDateTime!.minute,
            )
          : TimeOfDay.now(),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _controller.text = _formatDateTime(_selectedDateTime!);
    });

    if (!widget.isFormBuilder) widget.onChanged?.call(_selectedDateTime);
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Date & Time",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.calendar_today),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickDateTime,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
        ),
      ),
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<DateTime>(
        name: widget.name,
        initialValue: _selectedDateTime,
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
