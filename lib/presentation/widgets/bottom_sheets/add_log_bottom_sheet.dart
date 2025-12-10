import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_event.dart';
import 'package:my_daily_log/presentation/widgets/organisms/log_form.dart';
import 'package:my_daily_log/presentation/widgets/templates/form_bottom_sheet.dart';

class AddLogBottomSheet extends StatefulWidget {
  final DailyLog? log;

  const AddLogBottomSheet({super.key, this.log});

  @override
  State<AddLogBottomSheet> createState() => _AddLogBottomSheetState();
}

class _AddLogBottomSheetState extends State<AddLogBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _contentController = TextEditingController(text: widget.log?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveLog() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final log =
          widget.log?.copyWith(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            updatedAt: now,
          ) ??
          DailyLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            createdAt: now,
            updatedAt: now,
          );

      if (widget.log == null) {
        context.read<DailyLogBloc>().add(AddDailyLog(log));
      } else {
        context.read<DailyLogBloc>().add(UpdateDailyLog(log));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBottomSheet(
      title: widget.log == null ? 'New Log' : 'Edit Log',
      buttonText: widget.log == null ? 'Save' : 'Update',
      formKey: _formKey,
      onSubmit: _saveLog,
      child: LogForm(
        titleController: _titleController,
        contentController: _contentController,
      ),
    );
  }
}
