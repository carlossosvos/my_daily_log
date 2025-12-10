import 'package:flutter/material.dart';
import 'package:my_daily_log/presentation/widgets/molecules/bottom_sheet_header.dart';

class BaseBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final EdgeInsets? padding;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetHeader(
              title: title,
              onClose: onClose ?? () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
