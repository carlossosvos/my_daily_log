class DateFormatter {
  static String formatRelativeDate(DateTime date) {
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

  // You can add more date formatting methods here
  static String formatDateOnly(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTimeOnly(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
