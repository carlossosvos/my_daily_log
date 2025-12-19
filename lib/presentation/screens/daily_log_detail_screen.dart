import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_daily_log/core/utils/date_formatter.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_state.dart';
import 'package:my_daily_log/presentation/widgets/bottom_sheets/add_log_bottom_sheet.dart';

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
            onPressed: () => _showEditBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatRelativeDate(log.createdAt),
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (log.createdAt != log.updatedAt) ...[
                          const Spacer(),
                          Text(
                            'Updated ${DateFormatter.formatTimeOnly(log.updatedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    log.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Text(
                    log.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
