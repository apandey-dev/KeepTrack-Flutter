import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/auth_controller.dart';
import '../../services/auth_service.dart';
import '../../shared/pill_button.dart';

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final currentTheme = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondaryBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final displayName = user?.displayName ?? 'Valued User';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoURL;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile & Settings',
                    style: GoogleFonts.mali(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    // Profile Avatar (Google Photo or Initial Fallback)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackAvatar(initial, isDark),
                              )
                            : _buildFallbackAvatar(initial, isDark),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Name and Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mali(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Appearance / Theme Switcher
              Text(
                'Appearance',
                style: GoogleFonts.mali(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _ThemeOptionTile(
                    label: 'System',
                    icon: Icons.brightness_auto_rounded,
                    isSelected: currentTheme == ThemeMode.system,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _ThemeOptionTile(
                    label: 'Light',
                    icon: Icons.light_mode_outlined,
                    isSelected: currentTheme == ThemeMode.light,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _ThemeOptionTile(
                    label: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    isSelected: currentTheme == ThemeMode.dark,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Logout Button
              PillButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                isOutlined: true,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.mali(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark ? AppColors.pureWhite : AppColors.pureBlack;
    final selectedFg = isDark ? AppColors.pureBlack : AppColors.pureWhite;
    final unselectedBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final unselectedFg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? selectedBg : borderColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? selectedFg : unselectedFg,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedFg : unselectedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
