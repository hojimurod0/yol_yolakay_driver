import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/locale_cubit.dart';
import '../network/network_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Global wrapper that overlays an animated top banner whenever the internet disconnects.
class OfflineBannerWrapper extends StatefulWidget {
  const OfflineBannerWrapper({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  State<OfflineBannerWrapper> createState() => _OfflineBannerWrapperState();
}

class _OfflineBannerWrapperState extends State<OfflineBannerWrapper> {
  bool _isDismissed = false;

  void _dismissBanner() {
    HapticFeedback.lightImpact();
    setState(() => _isDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NetworkCubit, NetworkState>(
      listener: (context, state) {
        if (!state.isConnected) {
          setState(() => _isDismissed = false);
        }
      },
      builder: (context, networkState) {
        final isOffline = !networkState.isConnected;
        final isVisible = isOffline && !_isDismissed;

        final locale = context.watch<LocaleCubit>().state;
        final lang = locale.languageCode;
        final isRu = lang == 'ru';
        final isEn = lang == 'en';

        final offlineTitle = isRu
            ? 'Нет подключения к сети'
            : (isEn ? 'No Internet Connection' : 'Internet aloqasi mavjud emas');
        final offlineSubtitle = isRu
            ? 'Проверьте Wi-Fi или мобильные данные'
            : (isEn
                ? 'Check your Wi-Fi or mobile data'
                : 'Wi-Fi yoki mobil internetni tekshiring');

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            if (widget.child != null)
              RepaintBoundary(
                child: widget.child!,
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: IgnorePointer(
                  ignoring: !isVisible,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    offset: isVisible ? Offset.zero : const Offset(0, -1.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isVisible ? 1.0 : 0.0,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEE2E2),
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offlineTitle,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF991B1B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      offlineSubtitle,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : const Color(0xFFB91C1C),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: isDark ? Colors.white70 : const Color(0xFF991B1B),
                                onPressed: _dismissBanner,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
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
          ],
        );
      },
    );
  }
}
