import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_daily_log/core/utils/clipboard_utils.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_state.dart';
import 'package:my_daily_log/presentation/widgets/bottom_sheets/add_log_bottom_sheet.dart';
import 'package:my_daily_log/presentation/widgets/molecules/log_date_info_card.dart';

class DailyLogDetailScreen extends StatelessWidget {
  final String logId;

  const DailyLogDetailScreen({super.key, required this.logId});

  void _showEditBottomSheet(BuildContext context) {
    final state = context.read<DailyLogBloc>().state;

    if (state is! DailyLogLoaded) return;

    final log = state.logs.firstWhere(
      (log) => log.id == logId,
      orElse: () => state.logs.first,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Add this
      builder: (context) => AddLogBottomSheet(log: log),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this log?'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final bloc = context.read<DailyLogBloc>();
              Navigator.pop(context);
              bloc.add(DeleteDailyLog(logId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _showEditBottomSheet(context),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              final state = context.read<DailyLogBloc>().state;
              if (state is! DailyLogLoaded) return;
              final log = state.logs.firstWhere((log) => log.id == logId);

              switch (value) {
                case 'copy':
                  ClipboardUtils.copyLog(
                    context,
                    title: log.title,
                    content: log.content,
                  );
                  break;
                case 'share_text':
                  ClipboardUtils.shareLogText(
                    context,
                    title: log.title,
                    content: log.content,
                  );
                  break;
                case 'share_file':
                  ClipboardUtils.shareLogAsFile(
                    context,
                    title: log.title,
                    content: log.content,
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_text',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 12),
                    Text('Share as text'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_file',
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 20),
                    SizedBox(width: 12),
                    Text('Share as file'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<DailyLogBloc, DailyLogState>(
        listener: (context, state) {
          // Auto-navigate back if log is deleted
          if (state is DailyLogLoaded) {
            final logExists = state.logs.any((log) => log.id == logId);
            if (!logExists) {
              context.pop();
            }
          }
        },
        child: BlocBuilder<DailyLogBloc, DailyLogState>(
          builder: (context, state) {
            if (state is! DailyLogLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if log still exists
            final logIndex = state.logs.indexWhere((log) => log.id == logId);
            if (logIndex == -1) {
              // Log was deleted, show placeholder while navigating
              return const Center(child: CircularProgressIndicator());
            }

            final log = state.logs[logIndex];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      SelectableText(
                        log.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date info
                      LogDateInfoCard(
                        createdAt: log.createdAt,
                        updatedAt: log.updatedAt,
                      ),
                      const SizedBox(height: 24),
                      // Content
                      SelectableText(
                        log.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
