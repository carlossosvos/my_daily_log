import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const AppText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  const AppText.title(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : style = const TextStyle(
         fontWeight: FontWeight.w600,
         fontSize: 16,
         color: Colors.black87,
       );

  const AppText.bottomsheetTitle(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : style = const TextStyle(
         fontSize: 22,
         fontWeight: FontWeight.w600,
         color: Colors.black87,
       );

  const AppText.subtitle(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : style = const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4);

  const AppText.caption(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : style = const TextStyle(color: Colors.grey, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
