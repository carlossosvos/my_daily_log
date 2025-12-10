import 'package:flutter/material.dart';
import 'package:my_daily_log/presentation/widgets/atoms/app_button.dart';
import 'package:my_daily_log/presentation/widgets/templates/base_bottom_sheet.dart';

class FormBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final String buttonText;
  final VoidCallback onSubmit;
  final VoidCallback? onClose;
  final GlobalKey<FormState>? formKey;

  const FormBottomSheet({
    super.key,
    required this.title,
    required this.child,
    required this.buttonText,
    required this.onSubmit,
    this.onClose,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: title,
      onClose: onClose,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            const SizedBox(height: 24),
            AppButton(text: buttonText, onPressed: onSubmit),
          ],
        ),
      ),
    );
  }
}
