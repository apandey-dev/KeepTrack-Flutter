import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../services/auth_service.dart';
import '../../profile/profile_sheet.dart';

class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final greeting = AppDateUtils.getGreeting();
    final todayFormatted = AppDateUtils.formatHeaderDate(DateTime.now());

    final displayName = user?.displayName?.split(' ').first ?? 'Friend';
    final photoUrl = user?.photoURL;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting & Today's Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName',
                style: GoogleFonts.mali(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                todayFormatted,
                style: GoogleFonts.mali(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),

        // User Avatar Button
        GestureDetector(
          onTap: () => ProfileSheet.show(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String initial, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.mali(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
      ),
    );
  }
}
