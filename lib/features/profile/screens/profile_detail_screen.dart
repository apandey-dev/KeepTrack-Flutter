import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/auth_controller.dart';
import '../../tasks/task_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../shared/custom_snackbar.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.mali(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out from your account?',
          style: GoogleFonts.mali(
            fontSize: 14,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.mali(
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.mali(
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getProviderPhoto(dynamic user) {
    if (user == null) return null;
    try {
      for (final info in user.providerData) {
        if (info.photoURL != null && info.photoURL!.isNotEmpty) {
          return info.photoURL;
        }
      }
    } catch (_) {}
    return null;
  }

  String _getFallbackName(dynamic user) {
    if (user == null) return 'User';
    try {
      for (final info in user.providerData) {
        if (info.displayName != null && info.displayName!.trim().isNotEmpty) {
          return info.displayName!.trim();
        }
      }
      if (user.email != null && user.email!.contains('@')) {
        return user.email!.split('@').first;
      }
    } catch (_) {}
    return 'User';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authUser = ref.watch(authStateProvider).value;
    final userProfile = authUser != null
        ? ref.watch(userProfileProvider(authUser.uid)).value
        : null;
    final allTasksAsync = ref.watch(allTasksProvider);
    final currentTheme = ref.watch(themeModeProvider);

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final profileName = userProfile?.displayName?.trim();
    final authName = authUser?.displayName?.trim();
    final displayName = (profileName != null && profileName.isNotEmpty)
        ? profileName
        : (authName != null && authName.isNotEmpty)
            ? authName
            : _getFallbackName(authUser);

    final profilePhoto = userProfile?.photoUrl;
    final authPhoto = authUser?.photoURL;
    final photoUrl = (profilePhoto != null && profilePhoto.isNotEmpty)
        ? profilePhoto
        : (authPhoto != null && authPhoto.isNotEmpty)
            ? authPhoto
            : _getProviderPhoto(authUser);

    final email = (userProfile?.email.isNotEmpty == true)
        ? userProfile!.email
        : authUser?.email ?? 'No email associated';

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final providerId = authUser?.providerData.isNotEmpty == true
        ? authUser!.providerData.first.providerId
        : 'password';
    final isGoogleUser = providerId.contains('google');

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header (no back button, handled by mobile back)
              Text(
                'Profile & Account',
                style: GoogleFonts.mali(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your profile',
                style: GoogleFonts.mali(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 24),

              // User Profile Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Column(
                  children: [
                    // Large Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (_, _, _) =>
                                    _buildInitialAvatar(initial, isDark),
                              )
                            : _buildInitialAvatar(initial, isDark),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Display Name
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mali(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mali(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Provider Pill (Clean & Centered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGoogleUser ? Icons.g_mobiledata_rounded : Icons.mail_rounded,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isGoogleUser ? 'Google Sign-In' : 'Email Account',
                            style: GoogleFonts.mali(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Task Performance Statistics
              Text(
                'TASK STATS',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),

              allTasksAsync.when(
                data: (tasks) {
                  final total = tasks.length;
                  final completed = tasks.where((t) => t.isCompleted).length;
                  final pending = total - completed;
                  final rate = total == 0 ? 0 : ((completed / total) * 100).toInt();

                  return Row(
                    children: [
                      _buildStatBox(
                        title: 'Total',
                        value: '$total',
                        color: const Color(0xFF3B82F6),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildStatBox(
                        title: 'Done',
                        value: '$completed',
                        color: const Color(0xFF10B981),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildStatBox(
                        title: 'Pending',
                        value: '$pending',
                        color: const Color(0xFFF59E0B),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildStatBox(
                        title: 'Rate',
                        value: '$rate%',
                        color: const Color(0xFF8B5CF6),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                    ],
                  );
                },
                loading: () => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // Section: Theme & Appearance
              Text(
                'APPEARANCE',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildThemeTile(
                      label: 'System',
                      icon: Icons.brightness_auto_rounded,
                      isSelected: currentTheme == ThemeMode.system,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeTile(
                      label: 'Light',
                      icon: Icons.wb_sunny_rounded,
                      isSelected: currentTheme == ThemeMode.light,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeTile(
                      label: 'Dark',
                      icon: Icons.nightlight_round,
                      isSelected: currentTheme == ThemeMode.dark,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section: NOTIFICATIONS & REMINDERS
              Text(
                'NOTIFICATIONS & REMINDERS',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            size: 22,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduled Push Reminders',
                                style: GoogleFonts.mali(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: primaryTextColor,
                                ),
                              ),
                              Text(
                                'Fires alerts even when app is closed',
                                style: GoogleFonts.mali(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final granted =
                                  await NotificationService().requestPermissions();
                              if (context.mounted) {
                                AppSnackbar.show(
                                  context,
                                  message: granted
                                      ? 'Notification permission granted! ✅'
                                      : 'Notification permission denied. Please allow in settings.',
                                  isError: !granted,
                                );
                              }
                            },
                            icon: const Icon(Icons.security_rounded, size: 16),
                            label: Text(
                              'Permissions',
                              style: GoogleFonts.mali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryTextColor,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await NotificationService().showInstantNotification(
                                title: 'KeepTrack Reminder Test 🔔',
                                body:
                                    'Push notification received successfully in background!',
                              );
                              if (context.mounted) {
                                AppSnackbar.show(
                                  context,
                                  message:
                                      'Test notification triggered! Check your notification tray.',
                                );
                              }
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: Text(
                              'Test Alert',
                              style: GoogleFonts.mali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.white : const Color(0xFF111827),
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Sign Out Button
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _confirmSignOut(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    foregroundColor: Colors.redAccent,
                    backgroundColor: isDark
                        ? Colors.redAccent.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.04),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.mali(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initial, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.mali(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.mali(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.mali(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeBg = isDark ? Colors.white : const Color(0xFF111827);
    final activeFg = isDark ? Colors.black : Colors.white;
    final inactiveFg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeFg : inactiveFg,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
