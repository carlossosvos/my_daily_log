import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_event.dart';

class DailyLogEditScreen extends StatefulWidget {
  final DailyLog? log;

  const DailyLogEditScreen({super.key, this.log});

  @override
  State<DailyLogEditScreen> createState() => _DailyLogEditScreenState();
}

class _DailyLogEditScreenState extends State<DailyLogEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

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
    final isEditing = widget.log != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Log' : 'New Log',
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: _saveLog,
            child: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter log title',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write your thoughts...',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2),
                  ),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                maxLines: null,
                minLines: 15,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
