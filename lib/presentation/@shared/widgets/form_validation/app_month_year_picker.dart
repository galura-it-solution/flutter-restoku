import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppMonthYearPicker`
///
/// Widget untuk memilih **bulan & tahun** saja:
/// - Tidak menampilkan pilihan tanggal
/// - Bisa dipakai di **FormBuilder** atau manual
/// - Mendukung **initialValue** dan **onChanged**
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
///   child: AppMonthYearPicker(
///     name: "periode",
///     label: "Periode",
///     isFormBuilder: true,
///     initialValue: DateTime(2025, 8),
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// final controller = TextEditingController();
///
/// AppMonthYearPicker(
///   name: "periode",
///   label: "Periode",
///   isFormBuilder: false,
///   controller: controller,
///   initialValue: DateTime(2025, 8),
///   onChanged: (val) {
///     print("Selected: ${val!.month}/${val.year}");
///   },
/// );
/// ```
class AppMonthYearPicker extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final DateTime? initialValue;
  final Function(DateTime?)? onChanged;
  final bool disabled;
  final List<String? Function(DateTime?)>? validators;

  const AppMonthYearPicker({
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
  State<AppMonthYearPicker> createState() => _AppMonthYearPickerState();
}

class _AppMonthYearPickerState extends State<AppMonthYearPicker> {
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
          ? _formatMonthYear(widget.initialValue!)
          : '',
    );
    if (!widget.isFormBuilder &&
        widget.initialValue != null &&
        widget.controller != null) {
      widget.controller!.text = _formatMonthYear(widget.initialValue!);
    }
  }

  String _formatMonthYear(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  Future<void> _pickMonthYear() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year, now.month);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked == null) return;

    // Ambil hanya bulan & tahun
    final selected = DateTime(picked.year, picked.month);
    setState(() {
      _selectedDate = selected;
      _controller.text = _formatMonthYear(selected);
    });

    if (!widget.isFormBuilder) widget.onChanged?.call(selected);
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select Month/Year",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.date_range),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _pickMonthYear,
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
        initialValue: _selectedDate,
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
