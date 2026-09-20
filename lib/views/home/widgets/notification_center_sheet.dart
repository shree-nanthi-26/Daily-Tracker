import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/task_provider.dart';

class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(scheduledHabitRemindersProvider);
    final pendingCount = ref.watch(pendingRemindersCountProvider);
    final notificationService = ref.watch(notificationServiceProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    final uid = ref.watch(currentUserIdProvider);
    final todayStr = DateFormatter.todayIso();

    final pendingItems = reminders.where((r) => !r.isCompletedToday).toList();
    final completedItems = reminders.where((r) => r.isCompletedToday).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.borderCard, width: 1),
          left: BorderSide(color: AppColors.borderCard, width: 1),
          right: BorderSide(color: AppColors.borderCard, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.borderCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.tealAccent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Center',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pendingCount > 0
                            ? '$pendingCount habit reminder${pendingCount == 1 ? '' : 's'} pending today'
                            : 'All scheduled habits completed today! 🌟',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: pendingCount > 0
                              ? AppColors.textSecondary
                              : AppColors.greenSuccess,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Quick Action Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.navyPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Local Alarms',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Reminders trigger automatically on your device at set times.',
                        style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await notificationService.showInstantNotification(
                      title: 'DailyWork Reminder Test 🔥',
                      body: 'Your habit reminders and daily alarms are actively configured!',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent to device status bar!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: const Text('Test Alert', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 18),

          // Content List
          Expanded(
            child: reminders.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    children: [
                      if (pendingItems.isNotEmpty) ...[
                        _buildSectionHeader('PENDING TODAY', pendingItems.length, AppColors.warning),
                        const SizedBox(height: 8),
                        ...pendingItems.map((item) => _buildReminderTile(
                              context: context,
                              item: item,
                              uid: uid,
                              todayStr: todayStr,
                              firestore: firestore,
                            )),
                        const SizedBox(height: 16),
                      ],
                      if (completedItems.isNotEmpty) ...[
                        _buildSectionHeader('COMPLETED TODAY', completedItems.length, AppColors.greenSuccess),
                        const SizedBox(height: 8),
                        ...completedItems.map((item) => _buildReminderTile(
                              context: context,
                              item: item,
                              uid: uid,
                              todayStr: todayStr,
                              firestore: firestore,
                            )),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTile({
    required BuildContext context,
    required HabitReminderItem item,
    required String uid,
    required String todayStr,
    required dynamic firestore,
  }) {
    final habitColor = Color(
      int.tryParse(item.habit.color.replaceFirst('#', '0xFF')) ?? 0xFF0B2D4D,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isCompletedToday
            ? AppColors.greenSuccess.withValues(alpha: 0.04)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.isCompletedToday
              ? AppColors.greenSuccess.withValues(alpha: 0.3)
              : AppColors.borderCard,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Habit Color Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: habitColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Habit Title & Reminder Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.habit.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: item.isCompletedToday
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: item.isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Reminder Time Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.navyPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.tealAccent),
                          const SizedBox(width: 4),
                          Text(
                            item.reminderTimeStr,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Category pill
                    Text(
                      item.habit.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Checkbox Button
          IconButton(
            icon: Icon(
              item.isCompletedToday
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.isCompletedToday
                  ? AppColors.greenSuccess
                  : AppColors.borderCard,
              size: 26,
            ),
            tooltip: item.isCompletedToday ? 'Completed today' : 'Mark completed',
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await firestore.toggleCompletion(uid, item.habit.id, todayStr);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No Habit Reminders Set',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Edit any habit in the Habits tab to assign a reminder time (e.g. 07:00 AM) to receive daily alerts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
