import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../router/driver_router.dart';
import '../theme/app_colors.dart';

/// Centralized Top Floating Notification / Toast banner component.
/// Displays smoothly from the TOP of the screen without covering bottom navigation tabs.
abstract class AppSnackBar {
  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

  static void showError(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
    String? retryText,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.mediumImpact();
    _show(
      context: context,
      message: message,
      title: title,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.error,
      backgroundColor: const Color(0xFFDC2626),
      textColor: Colors.white,
      onAction: onRetry,
      actionLabel: retryText ?? 'Qayta urinish',
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();
    _show(
      context: context,
      message: message,
      title: title,
      icon: Icons.check_circle_rounded,
      accentColor: AppColors.success,
      backgroundColor: const Color(0xFF059669),
      textColor: Colors.white,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.selectionClick();
    _show(
      context: context,
      message: message,
      title: title,
      icon: Icons.warning_amber_rounded,
      accentColor: AppColors.warning,
      backgroundColor: const Color(0xFFD97706),
      textColor: Colors.white,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      title: title,
      icon: Icons.info_outline_rounded,
      accentColor: AppColors.taxiYellowDark,
      backgroundColor: const Color(0xFFD97706),
      textColor: Colors.white,
      duration: duration,
    );
  }

  static void _dismissActive() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }

  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required Color textColor,
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
    required Duration duration,
  }) {
    _dismissActive();

    final overlayState = driverRootNavigatorKey.currentState?.overlay ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay ??
        Overlay.maybeOf(context);

    if (overlayState == null) {
      // Fallback to standard ScaffoldMessenger if overlay is unavailable
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: backgroundColor,
            content: Text(message),
            duration: duration,
          ),
        );
      }
      return;
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastWidget(
        message: message,
        title: title,
        icon: icon,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        onAction: onAction,
        actionLabel: actionLabel,
        onDismiss: () {
          if (_activeEntry == entry) {
            _dismissActive();
          }
        },
      ),
    );

    _activeEntry = entry;
    overlayState.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_activeEntry == entry) {
        _dismissActive();
      }
    });
  }
}

class _TopToastWidget extends StatefulWidget {
  const _TopToastWidget({
    required this.message,
    this.title,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    this.onAction,
    this.actionLabel,
    required this.onDismiss,
  });

  final String message;
  final String? title;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback onDismiss;

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top + 10;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E2026) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E323D) : const Color(0xFFE5E7EB);
    final textCol = isDark ? Colors.white : const Color(0xFF111111);

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  _handleDismiss();
                }
              },
              child: SlideTransition(
                position: _offsetAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.title != null) ...[
                                Text(
                                  widget.title!,
                                  style: TextStyle(
                                    color: textCol,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: textCol,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.onAction != null && widget.actionLabel != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _handleDismiss();
                              widget.onAction!();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.backgroundColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.actionLabel!,
                                style: TextStyle(
                                  color: widget.backgroundColor,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white38 : Colors.black26,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
