import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMonthProvider = StateProvider<int>((ref) {
  return DateTime.now().month;
});

final selectedYearProvider = StateProvider<int>((ref) {
  return DateTime.now().year;
});

final daysInSelectedMonthProvider = Provider<int>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final year = ref.watch(selectedYearProvider);

  // DateTime(year, month + 1, 0).day gives the last day of the month
  return DateTime(year, month + 1, 0).day;
});

final selectedMonthNameProvider = Provider<String>((ref) {
  final month = ref.watch(selectedMonthProvider);
  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return monthNames[(month - 1).clamp(0, 11)];
});
