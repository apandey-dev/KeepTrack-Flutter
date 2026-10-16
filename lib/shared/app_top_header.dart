import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/theme_provider.dart';
import '../features/profile/screens/profile_detail_screen.dart';
import '../services/auth_service.dart';

class AppTopHeader extends ConsumerWidget {
  final bool isRecordTab;
  final ValueChanged<bool> onTabChanged;

  const AppTopHeader({
    super.key,
    required this.isRecordTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final pillBorder = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    final activeBg = isDark ? Colors.white : const Color(0xFF111827);
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: [ Today | Record ] Segmented Pill (Long press opens Profile & Sign Out)
          GestureDetector(
            onLongPress: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileDetailScreen(),
              ),
            ),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: pillBorder, width: 1.2),
              ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Today button
                GestureDetector(
                  onTap: () => onTabChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: !isRecordTab ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Today',
                      style: GoogleFonts.mali(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !isRecordTab ? activeText : inactiveText,
                      ),
                    ),
                  ),
                ),
                // Record button
                GestureDetector(
                  onTap: () => onTabChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: isRecordTab ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Record',
                      style: GoogleFonts.mali(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isRecordTab ? activeText : inactiveText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

          // Right: Sun / Moon Theme Toggle Pill + Profile Icon Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle Pill
              GestureDetector(
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(isDark),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: pillBorder, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sun icon
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: !isDark ? activeBg : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wb_sunny_rounded,
                          size: 16,
                          color: !isDark ? activeText : inactiveText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Moon icon
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? activeBg : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          size: 15,
                          color: isDark ? activeText : inactiveText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Profile Icon Button
              Consumer(
                builder: (context, ref, _) {
                  final authUser = ref.watch(authStateProvider).value;
                  final userProfile = authUser != null
                      ? ref.watch(userProfileProvider(authUser.uid)).value
                      : null;

                  String? getProviderPhoto(dynamic user) {
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

                  String getFallbackName(dynamic user) {
                    if (user == null) return 'U';
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
                    return 'U';
                  }

                  final profilePhoto = userProfile?.photoUrl;
                  final authPhoto = authUser?.photoURL;
                  final photoUrl = (profilePhoto != null && profilePhoto.isNotEmpty)
                      ? profilePhoto
                      : (authPhoto != null && authPhoto.isNotEmpty)
                          ? authPhoto
                          : getProviderPhoto(authUser);

                  final profileName = userProfile?.displayName?.trim();
                  final authName = authUser?.displayName?.trim();
                  final displayName = (profileName != null && profileName.isNotEmpty)
                      ? profileName
                      : (authName != null && authName.isNotEmpty)
                          ? authName
                          : getFallbackName(authUser);

                  final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileDetailScreen(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: pillBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: pillBorder, width: 1.2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 38,
                                height: 38,
                                errorBuilder: (_, _, _) => _buildFallbackAvatar(initial, isDark),
                              )
                            : _buildFallbackAvatar(initial, isDark),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String? initial, bool isDark) {
    if (initial != null && initial.isNotEmpty) {
      return Text(
        initial,
        style: GoogleFonts.mali(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      );
    }
    return Icon(
      Icons.person_outline_rounded,
      size: 18,
      color: isDark ? Colors.white : const Color(0xFF111827),
    );
  }
}
