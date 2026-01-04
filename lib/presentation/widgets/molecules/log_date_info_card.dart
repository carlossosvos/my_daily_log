import 'package:flutter/material.dart';
import 'package:my_daily_log/core/utils/date_formatter.dart';

class LogDateInfoCard extends StatelessWidget {
  final DateTime createdAt;
  final DateTime updatedAt;

  const LogDateInfoCard({
    super.key,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final bool wasEdited = createdAt != updatedAt;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                'Created ${DateFormatter.formatRelativeDate(createdAt)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (wasEdited) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Last updated ${DateFormatter.formatRelativeDate(updatedAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
