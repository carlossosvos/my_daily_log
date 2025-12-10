import 'package:flutter/material.dart';
import 'package:my_daily_log/presentation/widgets/atoms/app_icon_button.dart';
import 'package:my_daily_log/presentation/widgets/atoms/app_text.dart';

class BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const BottomSheetHeader({super.key, required this.title, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.bottomsheetTitle(title),
        if (onClose != null)
          AppIconButton(icon: Icons.close, onPressed: onClose!),
      ],
    );
  }
}
