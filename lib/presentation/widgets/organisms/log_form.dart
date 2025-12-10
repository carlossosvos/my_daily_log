import 'package:flutter/material.dart';
import 'package:my_daily_log/presentation/widgets/atoms/app_text_field.dart';

class LogForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const LogForm({
    super.key,
    required this.titleController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: titleController,
          labelText: 'Title',
          hintText: 'Enter log title',
          autofocus: true,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: contentController,
          labelText: 'Content',
          hintText: 'Write your thoughts...',
          maxLines: 8,
          minLines: 4,
        ),
      ],
    );
  }
}
