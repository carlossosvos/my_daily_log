import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardUtils {
  /// Copy text to clipboard and show a snackbar
  static void copyToClipboard(
    BuildContext context,
    String text, {
    String? message,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Copy log content (title + content) to clipboard
  static void copyLog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final text = '$title\n\n$content';
    copyToClipboard(context, text, message: 'Log copied to clipboard');
  }

  /// Share log by copying to clipboard
  /// TODO: Replace with native share when implementing share_plus package
  static void shareLog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final text = '$title\n\n$content';
    copyToClipboard(
      context,
      text,
      message: 'Log copied to clipboard - ready to share!',
    );
  }
}
