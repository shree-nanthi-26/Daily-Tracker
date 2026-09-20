import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _ymdFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _readableFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _dayOfWeekFormat = DateFormat('E');

  static String toIsoDate(DateTime date) {
    return _ymdFormat.format(date);
  }

  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static String formatDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';

    if (date.year == now.year) {
      return _shortDateFormat.format(date);
    }
    return _readableFormat.format(date);
  }

  static String formatShortDay(DateTime date) {
    return _dayOfWeekFormat.format(date); // Mon, Tue, etc.
  }

  static List<DateTime> getCurrentWeekDays() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    return List.generate(7, (index) {
      final d = monday.add(Duration(days: index));
      return DateTime(d.year, d.month, d.day);
    });
  }

  static String todayIso() {
    return toIsoDate(DateTime.now());
  }
}
