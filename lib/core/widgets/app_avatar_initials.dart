import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable avatar widget that computes initials from a user's name,
/// renders custom background color themes or preset icons, or falls back gracefully.
class AppAvatarInitials extends StatelessWidget {
  const AppAvatarInitials({
    super.key,
    this.name,
    this.avatarUrl,
    this.size = 44.0,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  final String? name;
  final String? avatarUrl;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  static Color? parseColorFromUrl(String? url) {
    if (url == null || !url.contains('color:')) return null;
    final match =
        RegExp(r'color:(0x[0-9a-fA-F]+|#[0-9a-fA-F]+)').firstMatch(url);
    if (match != null) {
      final str = match.group(1)!;
      try {
        if (str.startsWith('#')) {
          final hex = str.replaceFirst('#', '');
          return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
        } else if (str.startsWith('0x')) {
          return Color(int.parse(str));
        }
      } catch (_) {}
    }
    return null;
  }

  static IconData? parseIconFromUrl(String? url) {
    if (url == null || !url.contains('icon:')) return null;
    if (url.contains('icon:car')) return Icons.directions_car_rounded;
    if (url.contains('icon:star')) return Icons.star_rounded;
    if (url.contains('icon:verified')) return Icons.verified_user_rounded;
    if (url.contains('icon:steering')) return Icons.navigation_rounded;
    if (url.contains('icon:person')) return Icons.person_rounded;
    return null;
  }

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool _isHttpUrl(String? url) {
    if (url == null) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final parsedBg = parseColorFromUrl(avatarUrl);
    final customIcon = parseIconFromUrl(avatarUrl);
    final hasNetworkImage = _isHttpUrl(avatarUrl);

    final bg = backgroundColor ??
        parsedBg ??
        (isDark ? AppColors.surfaceSubtleDark : AppColors.primaryLight);
    final fg = textColor ??
        (parsedBg != null
            ? (parsedBg.computeLuminance() > 0.5
                ? AppColors.charcoalBlack
                : Colors.white)
            : (isDark ? AppColors.primaryLight : AppColors.primaryDark));

    if (hasNetworkImage) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.12),
            width: 1.0,
          ),
          image: DecorationImage(
            image: NetworkImage(avatarUrl!),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.14),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            )
          : (customIcon != null
              ? Icon(
                  customIcon,
                  size: size * 0.52,
                  color: fg,
                )
              : Icon(
                  Icons.person_rounded,
                  size: size * 0.55,
                  color: fg,
                )),
    );
  }
}
