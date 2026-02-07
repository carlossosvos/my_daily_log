import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  static Future<void> shareLogText(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final text = '$title\n\n$content';
    try {
      await SharePlus.instance.share(ShareParams(subject: title, text: text));
    } catch (_) {
      // Fallback to clipboard
      if (context.mounted) {
        copyToClipboard(
          context,
          text,
          message: 'Log copied to clipboard - ready to share!',
        );
      }
    }
  }

  /// Create a temporary .txt file and share it via native share sheet
  static Future<void> shareLogAsFile(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final safeName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final fileName = '${safeName.isEmpty ? 'log' : safeName}.txt';

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString('$title\n\n$content');

      final xfile = XFile(file.path);
      await SharePlus.instance.share(
        ShareParams(subject: title, text: content, files: [xfile]),
      );
    } catch (e) {
      // Fallback to text share
      if (context.mounted) {
        await shareLogText(context, title: title, content: content);
      }
    }
  }
}
