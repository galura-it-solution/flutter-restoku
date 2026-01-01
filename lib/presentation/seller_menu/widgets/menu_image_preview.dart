import 'dart:io';

import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';

class MenuImagePreview extends StatelessWidget {
  const MenuImagePreview({
    super.key,
    required this.filePath,
    required this.imageUrl,
  });

  final String? filePath;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;
    final hasUrl = imageUrl.trim().isNotEmpty;

    Widget content;
    if (hasFile) {
      content = Image.file(
        File(filePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              color: MasterColor.dark_30,
            ),
          );
        },
      );
    } else if (hasUrl) {
      content = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              color: MasterColor.dark_30,
            ),
          );
        },
      );
    } else {
      content = const Center(
        child: Text(
          'Pratinjau gambar',
          style: TextStyle(color: MasterColor.dark_40),
        ),
      );
    }

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MasterColor.dark_10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}
