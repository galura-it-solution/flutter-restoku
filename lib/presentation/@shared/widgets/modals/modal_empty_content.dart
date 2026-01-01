import 'package:flutter/material.dart';

class Constants {
  Constants._();
  static const double padding = 3;
}

/// Dialog pop up tanpa content/masih kosong
class ModalEmptyContent extends StatefulWidget {
  final Widget child;
  final bool canScrolling;
  final double width;
  final double? height; // ⬅️ ubah jadi nullable
  final double borderRadius;

  const ModalEmptyContent({
    super.key,
    required this.child,
    required this.canScrolling,
    required this.width,
    this.height, // ⬅️ opsional
    this.borderRadius = 10,
  });

  @override
  State<ModalEmptyContent> createState() => _ModalEmptyContentState();
}

class _ModalEmptyContentState extends State<ModalEmptyContent> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    final container = Container(
      width: widget.width,
      height: widget.height, // ⬅️ kalau null, otomatis fit-to-content
      padding: EdgeInsets.all(widget.borderRadius),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );

    return widget.canScrolling
        ? SingleChildScrollView(child: Center(child: container))
        : Center(child: container);
  }
}
