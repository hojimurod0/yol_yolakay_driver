import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_info_provider.dart';
import '../providers/core_providers.dart';

/// Global wrapper that overlays an animated top banner whenever the internet disconnects or recovers.
/// Users can dismiss it via a close button (X) or swipe up.
class OfflineBannerWrapper extends ConsumerStatefulWidget {
  const OfflineBannerWrapper({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  ConsumerState<OfflineBannerWrapper> createState() =>
      _OfflineBannerWrapperState();
}

class _OfflineBannerWrapperState extends ConsumerState<OfflineBannerWrapper> {
  bool _isRetrying = false;
  bool _isDismissed = false;

  Future<void> _handleRetry() async {
    HapticFeedback.mediumImpact();
    setState(() => _isRetrying = true);
    await ref.read(networkStatusProvider.notifier).retryConnection();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isRetrying = false);
    }
  }

  void _dismissBanner() {
    HapticFeedback.lightImpact();
    setState(() => _isDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to network status changes to automatically re-show banner if status transitions
    ref.listen<NetworkStatus>(networkStatusProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() => _isDismissed = false);
      }
    });

    final status = ref.watch(networkStatusProvider);
    final locale = ref.watch(localeNotifierProvider);
    final lang = locale.languageCode;
    final isRu = lang == 'ru';
    final isEn = lang == 'en';

    final isOffline = status == NetworkStatus.offline;
    final isRestored = status == NetworkStatus.restored;
    final isVisible = (isOffline || isRestored) && !_isDismissed;

    final offlineTitle = isRu
        ? 'Нет подключения к сети'
        : (isEn ? 'No Internet Connection' : 'Internet aloqasi mavjud emas');
    final restoredTitle = isRu
        ? 'Подключение восстановлено'
        : (isEn ? 'Connection Restored' : 'Internet aloqasi tiklandi');
    final offlineSubtitle = isRu
        ? 'Проверьте Wi-Fi или мобильные данные'
        : (isEn
            ? 'Check your Wi-Fi or mobile data'
            : 'Wi-Fi yoki mobil internetni tekshiring');
    final restoredSubtitle = isRu
        ? 'Все сервисы работают в штатном режиме'
        : (isEn
            ? 'All services are back online'
            : 'Barcha xizmatlar onlayn rejimda');
    final retryText = isRu ? 'Повтор' : (isEn ? 'Retry' : 'Tekshirish');

    return Stack(
      children: [
        if (widget.child != null)
          RepaintBoundary(
            child: widget.child!,
          ),

        // Animated Top Banner with isolated repaint boundary
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
                    bottom: false,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < 0) {
                          _dismissBanner();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isOffline
                              ? const Color(0xFFE11D48) // Vibrant Rose / Red
                              : const Color(0xFF10B981), // Emerald Green
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isOffline
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF10B981))
                                  .withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isOffline
                                      ? Icons.wifi_off_rounded
                                      : Icons.wifi_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isOffline ? offlineTitle : restoredTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      isOffline
                                          ? offlineSubtitle
                                          : restoredSubtitle,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOffline) ...[
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: _isRetrying ? null : _handleRetry,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: _isRetrying
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Color(0xFFE11D48),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            retryText,
                                            style: const TextStyle(
                                              color: Color(0xFFE11D48),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 4),
                              // Direct Dismiss / Close (X) button
                              InkWell(
                                onTap: _dismissBanner,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
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
          ),
        ),
      ],
    );
  }
}
