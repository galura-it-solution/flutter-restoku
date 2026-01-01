import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
    this.onRetry,
    this.onRefresh,
    this.childIsScrollable = false,
  });

  final bool loading;
  final String errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final Widget child;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final bool childIsScrollable;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      );
    } else if (isEmpty) {
      content = Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: MasterColor.dark_50),
        ),
      );
    } else {
      content = child;
    }

    if (onRefresh == null) {
      return content;
    }

    if (content is ScrollView ||
        (childIsScrollable && identical(content, child))) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: content),
            ),
          );
        },
      ),
    );
  }
}
