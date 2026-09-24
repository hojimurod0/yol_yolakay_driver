import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/app_logger.dart';

/// Global or local Error Boundary widget that intercepts uncaught build/render errors
/// and presents a refined recovery card with a retry option rather than the red crash screen.
class AppErrorBoundary extends StatefulWidget {
  final Widget? child;
  final String? customMessage;
  final VoidCallback? onReset;

  const AppErrorBoundary({
    super.key,
    required this.child,
    this.customMessage,
    this.onReset,
  });

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  ErrorWidgetBuilder? _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _errorDetails == null) {
          AppLogger.error(
            'AppErrorBoundary caught FlutterErrorDetails',
            module: LogModule.system,
            error: details.exception,
            stackTrace: details.stack,
          );
          setState(() {
            _errorDetails = details;
          });
        }
      });
      return _buildErrorCard(context);
    };
  }

  @override
  void dispose() {
    if (_previousBuilder != null) {
      ErrorWidget.builder = _previousBuilder!;
    }
    super.dispose();
  }

  void _resetError() {
    setState(() {
      _errorDetails = null;
    });
    widget.onReset?.call();
  }

  Widget _buildErrorCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.error,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ilovani qayta yuklash talab etiladi',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.customMessage ??
                        'Kutilmagan vizual xatolik yuz berdi. Tugmani bosib ekranni qayta yuklang.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _resetError,
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text('Qaytadan urinish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.taxiYellow,
                        foregroundColor: AppColors.charcoalBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderMd),
                        elevation: 0,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return _buildErrorCard(context);
    }
    return widget.child ?? const SizedBox.shrink();
  }
}
