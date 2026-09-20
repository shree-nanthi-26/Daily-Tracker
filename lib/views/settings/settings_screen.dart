import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text(
          'Edit Display Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            labelText: 'Display Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(userDisplayNameProvider.notifier).updateDisplayName(newName);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Display name updated successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) async {
    setState(() => _isExporting = true);
    final storage = ref.read(localStorageServiceProvider);
    final jsonString = await storage.exportAllDataAsJson();
    setState(() => _isExporting = false);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Row(
          children: [
            Icon(Icons.cloud_download_rounded, color: AppColors.tealAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'Workspace JSON Backup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complete snapshot of your tasks, habits, completions, and goals:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navyPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup JSON copied to clipboard!'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text(
              'Reset All Local Data?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all local tasks, habits, completions, and goals from this device. This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final storage = ref.read(localStorageServiceProvider);
              await storage.clearAll();
              final firestore = ref.read(firestoreServiceProvider);
              firestore.clearSampleData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All local workspace data was successfully reset.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Yes, Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = ref.watch(userDisplayNameProvider);
    final activeThemeMode = ref.watch(themeModePreferenceProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final stats = ref.watch(dataStatsProvider);

    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    final isGuest = ref.watch(isGuestSignedInProvider);
    final userEmail = currentUser?.email ?? (isGuest ? 'guest_offline@dailywork.local' : 'shree@dailywork.app');
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. USER PROFILE CARD
              _buildCardContainer(
                title: 'User Profile & Account',
                icon: Icons.person_outline_rounded,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with initial
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.navyPrimary, AppColors.tealAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: AppColors.borderActive, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tealAccent.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initialLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _showEditNameDialog(context, displayName),
                                    borderRadius: BorderRadius.circular(4),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.edit_outlined, size: 16, color: AppColors.tealAccent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Connection Mode Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (currentUser != null && !isGuest)
                                      ? AppColors.greenSuccess.withValues(alpha: 0.12)
                                      : AppColors.tealAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (currentUser != null && !isGuest)
                                        ? AppColors.greenSuccess.withValues(alpha: 0.3)
                                        : AppColors.tealAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (currentUser != null && !isGuest)
                                            ? AppColors.greenSuccess
                                            : AppColors.tealAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (currentUser != null && !isGuest)
                                          ? 'Cloud Synchronized'
                                          : 'Local Offline Mode',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: (currentUser != null && !isGuest)
                                            ? AppColors.greenSuccess
                                            : AppColors.navyPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Password Reset Action Row
                    Row(
                      children: [
                        const Icon(Icons.lock_reset_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Password & Security',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await authService.sendPasswordResetEmail(userEmail);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Password reset instructions sent to $userEmail'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Reset Password'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. APPEARANCE & THEME SECTION
              _buildCardContainer(
                title: 'Appearance & Interaction',
                icon: Icons.palette_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'App Theme Mode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select visual style and contrast level across all dashboard widgets.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    // Theme Choice Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 450;
                        return isNarrow
                            ? Column(
                                children: AppThemeMode.values.map((mode) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: _buildThemeCard(mode, activeThemeMode),
                                  );
                                }).toList(),
                              )
                            : Row(
                                children: AppThemeMode.values.map((mode) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: _buildThemeCard(mode, activeThemeMode),
                                    ),
                                  );
                                }).toList(),
                              );
                      },
                    ),

                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Haptic Feedback Switch
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.vibration_rounded, color: AppColors.tealAccent, size: 20),
                      title: const Text(
                        'Tactile Haptic Feedback',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Vibrate on completing habits, checking tasks, and goal celebrations',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      value: hapticsEnabled,
                      activeTrackColor: AppColors.tealAccent.withValues(alpha: 0.4),
                      activeThumbColor: AppColors.tealAccent,
                      onChanged: (val) {
                        if (val) HapticFeedback.mediumImpact();
                        ref.read(hapticsEnabledProvider.notifier).setEnabled(val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. WORKSPACE DATA MANAGEMENT & BACKUP
              _buildCardContainer(
                title: 'Data Management & Backup',
                icon: Icons.storage_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Metrics Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.navyPrimary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderCard),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Tasks', '${stats.completedTasks}/${stats.totalTasks}'),
                          _buildDivider(),
                          _buildStatItem('Habits', '${stats.activeHabits} active'),
                          _buildDivider(),
                          _buildStatItem('Check-ins', '${stats.totalCompletions}'),
                          _buildDivider(),
                          _buildStatItem('Goals', '${stats.achievedGoals}/${stats.totalGoals}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Export JSON Backup Button
                    OutlinedButton.icon(
                      onPressed: _isExporting ? null : () => _showExportDialog(context),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export Workspace Backup (JSON)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Clear Demo Data Button
                    OutlinedButton.icon(
                      onPressed: () {
                        final firestore = ref.read(firestoreServiceProvider);
                        firestore.clearSampleData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sample demo items cleared. Ready for your own habits and tasks!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.tealAccent),
                      label: const Text('Clear Demo Data (Start Fresh)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Destructive Reset Button
                    OutlinedButton.icon(
                      onPressed: () => _showResetConfirmDialog(context),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.danger),
                      label: const Text('Reset All Local Data', style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. ABOUT & LOGOUT CARD
              _buildCardContainer(
                title: 'About DailyWork',
                icon: Icons.info_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Version',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'v1.0.0 (Flutter Rebuild)',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'DailyWork Mobile is designed to accompany your desktop productivity workflow, ensuring continuous habit consistency, target tracking, and offline persistence on the go.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Sign Out Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign Out'),
                      onPressed: () async {
                        ref.read(isGuestSignedInProvider.notifier).state = false;
                        await authService.signOut();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeMode mode, AppThemeMode activeMode) {
    final isSelected = mode == activeMode;

    Color previewBg;
    Color previewAccent;

    switch (mode) {
      case AppThemeMode.deepNavy:
        previewBg = AppColors.navyPrimary;
        previewAccent = AppColors.tealAccent;
        break;
      case AppThemeMode.amoledBlack:
        previewBg = Colors.black;
        previewAccent = const Color(0xFF38BDF8);
        break;
      case AppThemeMode.modernLight:
        previewBg = const Color(0xFFF1F5F9);
        previewAccent = const Color(0xFF0D9488);
        break;
    }

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeModePreferenceProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealAccent.withValues(alpha: 0.08) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.tealAccent : AppColors.borderCard,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Swatch preview box
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: previewBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: previewAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.tealAccent, size: 18)
                else
                  const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mode.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.navyPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              mode.description,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navyPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 26,
      color: AppColors.borderCard,
    );
  }

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCard, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.navyHeader,
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.tealAccent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textOnNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}
