import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

bool _dark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _ink(BuildContext context) =>
    _dark(context) ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

Color _muted(BuildContext context) =>
    _dark(context) ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

/// Small caps label above a group ("MASHINA", "BUGUN").
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: _muted(context),
        ),
      ),
    );
  }
}

/// Bordered white card holding rows separated by thin dividers.
class AppInfoGroup extends StatelessWidget {
  const AppInfoGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = _dark(context);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 14, endIndent: 14, color: border),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One row: optional leading icon, title (+ subtitle) and a trailing widget.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.bold = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final isDark = _dark(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceSubtleDark
                    : AppColors.surfaceSubtleLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: _ink(context)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: _ink(context),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12.5, color: _muted(context)),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (onTap != null && trailing == null)
            Icon(Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// A labelled value: label on top, value below (profile fields).
class AppFieldRow extends StatelessWidget {
  const AppFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: _muted(context))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: _ink(context),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// Tile in a row of stats ("★ 4.9 / reyting").
class AppStatTile extends StatelessWidget {
  const AppStatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = _dark(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink(context),
              ),
            ),
            Text(label,
                style: TextStyle(fontSize: 12, color: _muted(context))),
          ],
        ),
      ),
    );
  }
}

enum AppStatusTone { good, neutral, warning, bad }

/// Small rounded status label ("Yakunlandi", "Bekor qilindi").
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.label, required this.tone});

  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = _dark(context);
    final (Color bg, Color fg) = switch (tone) {
      AppStatusTone.good => (
          AppColors.success.withValues(alpha: isDark ? 0.18 : 0.14),
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)
        ),
      AppStatusTone.warning => (
          AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.22),
          isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E)
        ),
      AppStatusTone.bad => (
          AppColors.error.withValues(alpha: isDark ? 0.18 : 0.10),
          isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C)
        ),
      AppStatusTone.neutral => (
          isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
          _muted(context)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/// A history row: "07:00 · Jalaquduq → Andijon", details, amount + status.
class AppHistoryRow extends StatelessWidget {
  const AppHistoryRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final AppStatusChip status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _ink(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12.5, color: _muted(context))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _ink(context),
                  ),
                ),
                const SizedBox(height: 4),
                status,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Day headings for history lists: "Bugun", "Kecha", "21-oktabr".
class AppDayLabels {
  const AppDayLabels({
    required this.today,
    required this.yesterday,
    required this.localeTag,
  });

  final String today;
  final String yesterday;

  /// `uz`, `uz_Cyrl`, `ru` or `en`.
  final String localeTag;

  static const _months = {
    'uz': ['yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun', 'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'],
    'uz_Cyrl': ['январ', 'феврал', 'март', 'апрел', 'май', 'июн', 'июл', 'август', 'сентабр', 'октабр', 'ноябр', 'декабр'],
    'ru': ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
    'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  };

  String of(DateTime day, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final d = DateTime(day.year, day.month, day.day);
    final t = DateTime(n.year, n.month, n.day);
    final diff = t.difference(d).inDays;
    if (diff == 0) return today;
    if (diff == 1) return yesterday;
    final month = (_months[localeTag] ?? _months['uz']!).elementAt(d.month - 1);
    final dayMonth = switch (localeTag) {
      'en' => '$month ${d.day}',
      'ru' => '${d.day} $month',
      _ => '${d.day}-$month',
    };
    return d.year == t.year ? dayMonth : '$dayMonth ${d.year}';
  }
}

/// Items grouped under day headings, newest day first.
class AppDateGroupedList<T> extends StatelessWidget {
  const AppDateGroupedList({
    super.key,
    required this.items,
    required this.dateOf,
    required this.itemBuilder,
    required this.labels,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 32),
    this.newestFirst = true,
  });

  final List<T> items;
  final DateTime Function(T) dateOf;
  final Widget Function(BuildContext, T) itemBuilder;
  final AppDayLabels labels;
  final EdgeInsets padding;
  final bool newestFirst;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) => newestFirst
        ? dateOf(b).compareTo(dateOf(a))
        : dateOf(a).compareTo(dateOf(b)));
    final groups = <DateTime, List<T>>{};
    for (final item in sorted) {
      final d = dateOf(item);
      groups.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(item);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: [
        for (final entry in groups.entries) ...[
          AppSectionLabel(labels.of(entry.key)),
          AppInfoGroup(
            children: [for (final item in entry.value) itemBuilder(context, item)],
          ),
        ],
      ],
    );
  }
}
