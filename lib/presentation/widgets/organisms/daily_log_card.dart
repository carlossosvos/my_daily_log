import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log_event.dart';
import 'package:my_daily_log/presentation/widgets/atoms/app_text.dart';
import 'package:my_daily_log/presentation/widgets/bottom_sheets/add_log_bottom_sheet.dart';
import 'package:my_daily_log/presentation/widgets/molecules/app_slidable_action.dart';
import 'package:my_daily_log/presentation/widgets/molecules/confirmation_dialog.dart';

class DailyLogCard extends StatelessWidget {
  final DailyLog log;
  final VoidCallback onTap;

  const DailyLogCard({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey('slidable_${log.id}'),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.3,
            children: [
              AppSlidableAction(
                onPressed: () => _handleEdit(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                icon: Icons.edit,
              ),
              AppSlidableAction(
                onPressed: () => _showDeleteDialog(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                icon: Icons.delete,
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title(log.title.isEmpty ? 'Untitled' : log.title),
                    if (log.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      AppText.subtitle(
                        log.content.length > 100
                            ? '${log.content.substring(0, 100)}...'
                            : log.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    AppText.caption(_formatDate(log.createdAt)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLogBottomSheet(log: log),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Log',
        content: 'Are you sure you want to delete this log?',
        confirmText: 'Delete',
        confirmTextColor: Colors.red,
        onConfirm: () {
          context.read<DailyLogBloc>().add(DeleteDailyLog(log.id));
          Navigator.pop(context);
        },
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
