import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppTimePicker`
///
/// Widget time picker:
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
///   child: AppTimePicker(
///     name: "meeting_time",
///     label: "Meeting Time",
///     isFormBuilder: true,
///     initialValue: TimeOfDay(hour: 14, minute: 30),
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder, dengan initial value)
/// ```dart
/// final timeController = TextEditingController();
///
/// AppTimePicker(
///   name: "meeting_time",
///   label: "Meeting Time",
///   isFormBuilder: false,
///   controller: timeController,
///   initialValue: TimeOfDay(hour: 14, minute: 30),
///   onChanged: (val) {
///     print("Selected: $val");
///   },
/// );
/// ```
class AppTimePicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final TimeOfDay? initialValue;
  final Function(TimeOfDay?)? onChanged;
  final bool disabled;
  final List<String? Function(TimeOfDay?)>? validators;

  const AppTimePicker({
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
  State<AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  late final TextEditingController _internalController;
  TimeOfDay? _selectedTime;

  TextEditingController get _controller => widget.isFormBuilder
      ? _internalController
      : (widget.controller ?? _internalController);

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialValue;
    _internalController = TextEditingController(
      text: widget.initialValue != null
          ? _formatTime(widget.initialValue!)
          : '',
    );
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = _formatTime(widget.initialValue!);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _controller.text = _formatTime(picked);
      });
      if (!widget.isFormBuilder) widget.onChanged?.call(picked);
    }
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Time",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.access_time),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickTime,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
        ),
      ),
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<TimeOfDay>(
        name: widget.name,
        initialValue: _selectedTime,
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
