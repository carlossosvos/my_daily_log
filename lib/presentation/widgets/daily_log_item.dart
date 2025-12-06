import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_event.dart';
import 'package:my_daily_log/presentation/widgets/add_log_bottom_sheet.dart';

class DailyLogItem extends StatelessWidget {
  final DailyLog log;
  final VoidCallback onTap;

  const DailyLogItem({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Slidable(
        key: ValueKey(log.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => _handleEdit(context),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              icon: Icons.edit_outlined,
              borderRadius: BorderRadius.zero,
              flex: 1,
              autoClose: true,
            ),
            SlidableAction(
              onPressed: (_) => _showDeleteDialog(context),
              backgroundColor: Colors.white,
              foregroundColor: Colors.red[600]!,
              icon: Icons.delete_outlined,
              borderRadius: BorderRadius.zero,
              flex: 1,
              autoClose: true,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title.isEmpty ? 'Untitled' : log.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (log.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          log.content.length > 100
                              ? '${log.content.substring(0, 100)}...'
                              : log.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(log.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLogBottomSheet(log: log),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
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
              context.read<DailyLogBloc>().add(DeleteDailyLog(log.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';

    if (difference.inDays == 0) {
      return 'Today at $timeString';
    } else if (difference.inDays == 1) {
      return 'Yesterday at $timeString';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago at $timeString';
    } else {
      return '${date.day}/${date.month}/${date.year} at $timeString';
    }
  }
}
