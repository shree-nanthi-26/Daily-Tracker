import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/task_provider.dart';

class DashboardSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onCloseDrawer;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onCloseDrawer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitsStreamProvider).value ?? [];
    final habits = allHabits.where((h) => !h.isArchived).toList();
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    final uid = ref.watch(currentUserIdProvider);

    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);

    final todayStr = DateFormatter.todayIso();

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      width: 250,
      color: AppColors.navySidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP BRANDING: Checkmark icon + Daily Work Tracker
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.sidebarBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.task_alt_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Daily Work Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (onCloseDrawer != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onCloseDrawer,
                  ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. NAVIGATION ITEMS
                  _buildNavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Tasks',
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.repeat_rounded,
                    label: 'Habits',
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.track_changes_rounded,
                    label: 'Goals',
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                  ),

                  const SizedBox(height: 14),

                  // 3. HABIT TRACKER BORDERED PANEL
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.sidebarBorder, width: 1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HABIT TRACKER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '• Daily •',
                          style: TextStyle(
                            color: AppColors.tealAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. CALENDAR ENTRIES
                  const Text(
                    'CALENDAR ENTRIES',
                    style: TextStyle(
                      color: AppColors.sidebarMutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Month Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.sidebarBorder, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        dropdownColor: AppColors.navyHeader,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70, size: 18),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(12, (i) {
                          return DropdownMenuItem<int>(
                            value: i + 1,
                            child: Text(monthNames[i]),
                          );
                        }),
                        onChanged: (newMonth) {
                          if (newMonth != null) {
                            ref.read(selectedMonthProvider.notifier).state =
                                newMonth;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Year Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.sidebarBorder, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        dropdownColor: AppColors.navyHeader,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70, size: 18),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [2024, 2025, 2026, 2027].map((y) {
                          return DropdownMenuItem<int>(
                            value: y,
                            child: Text('$y'),
                          );
                        }).toList(),
                        onChanged: (newYear) {
                          if (newYear != null) {
                            ref.read(selectedYearProvider.notifier).state =
                                newYear;
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. MY HABITS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Habits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          onTabSelected(2);
                          if (onCloseDrawer != null) onCloseDrawer!();
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.tealAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (habits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No habits created yet.',
                        style: TextStyle(color: AppColors.sidebarMutedText, fontSize: 11),
                      ),
                    )
                  else
                    ...habits.map((h) {
                      final isDone = completionsMap[h.id]?.contains(todayStr) ?? false;

                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          firestore.toggleCompletion(uid, h.id, todayStr, isCurrentlyDone: isDone);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.5, horizontal: 4),
                          child: Row(
                            children: [
                              // Habit Name on the LEFT
                              Expanded(
                                child: Text(
                                  h.title,
                                  style: TextStyle(
                                    color: isDone ? Colors.white70 : Colors.white,
                                    fontSize: 12,
                                    fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    decorationColor: Colors.white54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Checkbox on the RIGHT
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                  color: isDone ? AppColors.tealAccent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isDone ? AppColors.tealAccent : AppColors.sidebarBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: isDone
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // 6. SIDEBAR BOTTOM: Motivational Text + Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.sidebarBorder, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Small motivational text panel
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.navyPrimary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.sidebarBorder, width: 0.8),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'SMALL STEPS',
                        style: TextStyle(
                          color: AppColors.tealAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'BIG CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Bottom branding
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY WORK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'TRACKER',
                          style: TextStyle(
                            color: AppColors.tealAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTabSelected(index);
            if (onCloseDrawer != null) onCloseDrawer!();
          },
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarSelected : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : AppColors.sidebarMutedText,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.sidebarMutedText,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
