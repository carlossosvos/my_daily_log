import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCharacterCount;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final TextStyle? style;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.showCharacterCount = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofocus = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black87, width: 2),
        ),
        alignLabelWithHint: minLines != null && minLines! > 1,
        counterText: showCharacterCount ? null : '',
      ),
      style:
          style ??
          const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
    );
  }
}
