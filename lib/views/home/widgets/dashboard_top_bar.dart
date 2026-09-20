import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';

import '../../../providers/settings_provider.dart';
import '../../../providers/notification_provider.dart';
import 'notification_center_sheet.dart';

class DashboardTopBar extends ConsumerWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenSettings;
  final bool showDrawerButton;
  final String title;

  const DashboardTopBar({
    super.key,
    this.onOpenDrawer,
    this.onOpenSettings,
    this.showDrawerButton = false,
    this.title = 'Dashboard',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final displayName = ref.watch(userDisplayNameProvider);
    final pendingReminders = ref.watch(pendingRemindersCountProvider);
    final userEmail = user?.email ?? 'shree@dailywork.app';
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Breakpoint: Mobile screen vs desktop/tablet
        final isMobile = availableWidth < 600;
        final isSmallMobile = availableWidth < 360;

        // Responsive padding and spacing
        final horizontalPadding = isSmallMobile ? 10.0 : (isMobile ? 14.0 : 18.0);
        final showUserName = !isMobile;
        final itemSpacing = isMobile ? 8.0 : 12.0;

        return Container(
          height: 54,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: const BoxDecoration(
            color: Color(0xFF050505), // App header near-black #050505
            border: Border(
              bottom: BorderSide(color: Color(0xFF1E1E1E), width: 1),
            ),
          ),
          child: Row(
            children: [
              // LEFT SIDE: Menu icon (mobile) + App logo/icon + "Daily Work Tracker" title
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showDrawerButton && onOpenDrawer != null) ...[
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                        onPressed: onOpenDrawer,
                        tooltip: 'Open Navigation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      SizedBox(width: isSmallMobile ? 4 : 6),
                    ],

                    // App logo / icon
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    SizedBox(width: isSmallMobile ? 6 : 10),

                    // "Daily Work Tracker" title
                    const Flexible(
                      child: Text(
                        'Daily Work Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isMobile ? 6 : 12),

              // RIGHT SIDE: Notification Bell, Divider, User Avatar / Profile Dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notification bell icon with pending reminder badge
                  IconButton(
                    icon: Badge(
                      isLabelVisible: pendingReminders > 0,
                      backgroundColor: AppColors.tealAccent,
                      textColor: AppColors.navyPrimary,
                      label: Text(
                        '$pendingReminders',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Icon(
                        pendingReminders > 0
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: pendingReminders > 0 ? AppColors.tealAccent : Colors.white70,
                        size: 20,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => NotificationCenterSheet.show(context),
                    tooltip: pendingReminders > 0
                        ? '$pendingReminders Habit Reminder${pendingReminders == 1 ? '' : 's'} Pending'
                        : 'Notification Center',
                  ),

                  SizedBox(width: itemSpacing),

                  // Divider between notification bell and user profile
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFF222222),
                  ),

                  SizedBox(width: itemSpacing),

                  // User Profile Avatar + Dropdown
                  PopupMenuButton<String>(
                    tooltip: 'User Profile & Options',
                    offset: const Offset(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.borderCard),
                    ),
                    color: AppColors.bgCard,
                    onSelected: (value) async {
                      if (value == 'logout') {
                        ref.read(isGuestSignedInProvider.notifier).state = false;
                        await authService.signOut();
                      } else if (value == 'settings') {
                        onOpenSettings?.call();
                      } else if (value == 'clear_sample') {
                        final firestore = ref.read(firestoreServiceProvider);
                        firestore.clearSampleData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demo data cleared! You can now track your own real habits and tasks.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_rounded, size: 16, color: AppColors.tealAccent),
                            SizedBox(width: 8),
                            Text('Settings & Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'clear_sample',
                        child: Row(
                          children: [
                            Icon(Icons.refresh_rounded, size: 16, color: AppColors.tealAccent),
                            SizedBox(width: 8),
                            Text('Clear Demo Data (Start Fresh)', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
                            SizedBox(width: 8),
                            Text('Sign Out', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular user avatar
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.tealAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              initialLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        // On wider screens (desktop/tablet), show the full user name
                        if (showUserName) ...[
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ] else ...[
                          // On mobile screens, keep a compact dropdown arrow beside the avatar
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
