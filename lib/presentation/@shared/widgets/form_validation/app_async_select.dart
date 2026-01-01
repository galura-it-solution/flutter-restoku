import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:slims/core/constants/colors.dart';

/// 🔹 `AppAsyncSelect`
///
/// Widget dropdown dengan async search:
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
///   child: AppAsyncSelect(
///     name: "country",
///     label: "Country",
///     isFormBuilder: true,
///     initialValue: "USA",
///     fetchOptions: (query) async {
///       return ["USA", "UK", "India"]
///           .where((c) => c.toLowerCase().contains(query.toLowerCase()))
///           .toList();
///     },
///     validators: [FormBuilderValidators.required()],
///   ),
/// );
/// ```
///
/// ### 2️⃣ Mode Manual (tanpa FormBuilder, dengan initial value)
/// ```dart
/// final countryController = TextEditingController();
///
/// AppAsyncSelect(
///   name: "country",
///   label: "Country",
///   isFormBuilder: false,
///   controller: countryController,
///   initialValue: "UK",
///   fetchOptions: (query) async {
///     return ["USA", "UK", "India"]
///         .where((c) => c.toLowerCase().contains(query.toLowerCase()))
///         .toList();
///   },
///   onChanged: (val) {
///     print("Selected: $val");
///   },
/// );
/// ```
class AppAsyncSelect<T> extends StatefulWidget {
  final String name;
  final String? label;
  final bool isFormBuilder;
  final TextEditingController? controller;
  final T? initialValue;
  final Function(T?)? onChanged;
  final bool disabled;
  final List<String? Function(T?)>? validators;
  final Future<List<T>> Function(String) fetchOptions;

  const AppAsyncSelect({
    super.key,
    required this.name,
    required this.fetchOptions,
    this.label,
    this.isFormBuilder = true,
    this.controller,
    this.onChanged,
    this.initialValue,
    this.disabled = false,
    this.validators,
  });

  @override
  State<AppAsyncSelect<T>> createState() => _AppAsyncSelectState<T>();
}

class _AppAsyncSelectState<T> extends State<AppAsyncSelect<T>> {
  late T? _selectedItem;
  late TextEditingController _controller;
  List<T> _options = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
    _controller = widget.controller ?? TextEditingController();
    if (_selectedItem != null) {
      _controller.text = _selectedItem.toString();
    }
    // Fetch options awal saat widget ditampilkan
    _fetchInitialOptions();
  }

  Future<void> _fetchInitialOptions() async {
    try {
      final results = await widget.fetchOptions('');
      if (!mounted) return;
      setState(() {
        _options = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _options = [];
        _loading = false;
      });
    }
  }

  Future<void> _openSelectSheet() async {
    final selected = await showCupertinoModalBottomSheet<T>(
      context: context,
      expand: true,
      builder: (context) {
        final searchController = TextEditingController();

        // 🔹 Simpan state query di sini (scope builder, bukan dalam State class utama)
        List<T> sheetOptionsQuery = [];
        bool haveQuery = false;
        bool searching = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> search(String query) async {
              setModalState(() {
                haveQuery = query.isNotEmpty; // hanya true kalau ada input
                searching = true;
              });
              final results = await widget.fetchOptions(query);
              setModalState(() {
                sheetOptionsQuery = results;
                searching = false;
              });
            }

            final listOptions = haveQuery ? sheetOptionsQuery : _options;

            return Material(
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: search,
                                autocorrect: false, // 🚫 hilangkan autocorrect
                                enableSuggestions:
                                    false, // 🚫 hilangkan suggestion input
                                textCapitalization: TextCapitalization
                                    .none, // 🚫 tidak auto kapital
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      if (searching || _loading)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: listOptions.isEmpty && !(searching || _loading)
                            ? const Center(child: Text("No options"))
                            : ListView.builder(
                                itemCount: listOptions.length,
                                itemBuilder: (context, index) {
                                  final item = listOptions[index];
                                  final isSelected = _selectedItem == item;
                                  return ListTile(
                                    title: Text(item.toString()),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: MasterColor.success,
                                          )
                                        : null,
                                    onTap: () => Navigator.pop(context, item),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (mounted && selected != null) {
      setState(() {
        _selectedItem = selected;
        _controller.text = _selectedItem.toString();
      });
      if (!widget.isFormBuilder) widget.onChanged?.call(_selectedItem);
      if (widget.isFormBuilder) {
        final state = FormBuilder.of(context);
        state?.fields[widget.name]?.didChange(_selectedItem);
      }
    }
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Select",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabled: !widget.disabled,
      suffixIcon: const Icon(Icons.arrow_drop_down),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = GestureDetector(
      onTap: widget.disabled ? null : _openSelectSheet,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          enabled: !widget.disabled,
          decoration: _decoration(),
          autocorrect: false, // 🚫 hilangkan autocorrect
          enableSuggestions: false, // 🚫 hilangkan suggestion input
          textCapitalization: TextCapitalization.none, // 🚫 tidak auto kapital
        ),
      ),
    );

    if (widget.isFormBuilder) {
      return FormBuilderField<T>(
        name: widget.name,
        initialValue: _selectedItem,
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
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              field,
              if (fieldState.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fieldState.errorText!,
                    style: const TextStyle(color: MasterColor.danger),
                  ),
                ),
            ],
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        field,
      ],
    );
  }
}
