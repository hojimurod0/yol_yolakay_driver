import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable avatar widget that computes initials from a user's name or shows a fallback icon.
/// Designed specifically for YolYolakay where passenger profile photos are not required.
class AppAvatarInitials extends StatelessWidget {
  const AppAvatarInitials({
    super.key,
    this.name,
    this.size = 44.0,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = backgroundColor ??
        (isDark ? AppColors.surfaceSubtleDark : AppColors.primaryLight);
    final fg =
        textColor ?? (isDark ? AppColors.primaryLight : AppColors.primary);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: (fontSize != null
                      ? AppTypography.titleMedium.copyWith(fontSize: fontSize)
                      : AppTypography.titleMedium)
                  .copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: size * 0.55,
              color: fg,
            ),
    );
  }
}
