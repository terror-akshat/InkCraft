/// Utility functions for formatting dates in a user-friendly manner.
class DateFormatter {
  /// Format DateTime to a readable string (e.g., "Today 3:30 PM", "Yesterday", "Mar 15").
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (noteDate == today) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (noteDate == yesterday) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else if (now.difference(noteDate).inDays < 7) {
      return _getDayName(dateTime.weekday);
    } else {
      return '${_getMonthName(dateTime.month)} ${dateTime.day}';
    }
  }

  /// Format time to HH:MM AM/PM format.
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Get abbreviated day name.
  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get abbreviated month name.
  static String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}