import 'package:flutter/services.dart' show Clipboard, ClipboardData;

Future<void> copyToClipboard(String text, {void Function()? onCopied}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (onCopied is void Function()) onCopied();
}
