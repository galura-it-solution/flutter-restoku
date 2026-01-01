import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 AppAsyncMultiSelect
///
/// Input **multi select async**:
/// - Mendukung FormBuilder
/// - Bisa memanggil fungsi async untuk fetch opsi
/// - Bisa dipakai manual tanpa FormBuilder
///
/// ---
///
/// 📌 Contoh penggunaan:
///
/// ### 1️⃣ Mode FormBuilder
/// ```dart
/// FormBuilder(
///   key: _formKey,
///   child: AppAsyncMultiSelect<String>(
///     name: "users",
///     label: "Users",
///     isFormBuilder: true,
///     fetchOptions: (search) async {
///       // misal API call
///       return ["Alice", "Bob", "Charlie"]
///           .where((u) => u.toLowerCase().contains(search.toLowerCase()))
///           .toList();
///     },
///     initialValue: ["Alice"],
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual
/// ```dart
/// AppAsyncMultiSelect<String>(
///   name: "users",
///   label: "Users",
///   isFormBuilder: false,
///   fetchOptions: (search) async => ["Alice","Bob","Charlie"].where((u) => u.contains(search)).toList(),
///   initialValue: ["Bob"],
///   onChanged: (val) => print("Selected: $val"),
/// );
/// ```
class AppAsyncMultiSelect<T> extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final Future<List<T>> Function(String search) fetchOptions;
  final List<T>? initialValue;
  final Function(List<T>)? onChanged;
  final bool disabled;
  final List<String? Function(List<T>?)>? validators;

  const AppAsyncMultiSelect({
    super.key,
    required this.name,
    this.label,
    this.isFormBuilder = true,
    required this.fetchOptions,
    this.initialValue,
    this.onChanged,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppAsyncMultiSelect<T>> createState() => _AppAsyncMultiSelectState<T>();
}

class _AppAsyncMultiSelectState<T> extends State<AppAsyncMultiSelect<T>> {
  List<T> _selectedValues = [];
  List<T> _options = [];
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValues =
        widget.initialValue != null ? List.from(widget.initialValue!) : [];
    _fetchOptions('');
  }

  Future<void> _fetchOptions(String search) async {
    setState(() {
      _loading = true;
    });
    final results = await widget.fetchOptions(search);
    setState(() {
      _options = results;
      _loading = false;
    });
  }

  Widget _buildOptions(Function(List<T>)? onChangedCallback) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: _options.map((option) {
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
    final searchField = TextField(
      controller: _searchController,
      enabled: !widget.disabled,
      decoration: InputDecoration(
        hintText: "Search...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: _loading
            ? const CircularProgressIndicator()
            : const Icon(Icons.search),
      ),
      onChanged: (val) {
        _fetchOptions(val);
      },
    );

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
        searchField,
        const SizedBox(height: 8),
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
