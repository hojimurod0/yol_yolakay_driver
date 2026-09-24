import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clean & Modern Dot Wave (Nuqtali To'lqin) Pull-to-Refresh Indicator.
/// Smoothly displays 3 synchronized pulsing and waving glowing dots instead of default spinner.
class TaxiTurboRefresh extends StatefulWidget {
  const TaxiTurboRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.isDark = true,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final bool isDark;

  @override
  State<TaxiTurboRefresh> createState() => _TaxiTurboRefreshState();
}

class _TaxiTurboRefreshState extends State<TaxiTurboRefresh>
    with TickerProviderStateMixin {
  static const double _maxPullDistance = 75.0;
  static const double _refreshTriggerThreshold = 55.0;

  double _dragOffset = 0.0;
  bool _isRefreshing = false;

  late AnimationController _waveController;
  late AnimationController _settleController;
  late Animation<double> _settleAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(); // Continuously running for seamless live animation

    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _settleAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_settleController);

    _settleController.addListener(() {
      setState(() {
        _dragOffset = _settleAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _settleController.dispose();
    super.dispose();
  }

  void _startRefresh() async {
    if (_isRefreshing) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _isRefreshing = true;
      _dragOffset = _refreshTriggerThreshold;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _animateToZero();
      }
    }
  }

  void _animateToZero() {
    _settleAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOutCubic),
    );

    _settleController.reset();
    _settleController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0.0;
        });
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        final double newOffset =
            (-notification.metrics.pixels).clamp(0.0, _maxPullDistance);
        setState(() {
          _dragOffset = newOffset;
        });
      }
    } else if (notification is ScrollEndNotification ||
        notification is UserScrollNotification) {
      if (_dragOffset >= _refreshTriggerThreshold && !_isRefreshing) {
        _startRefresh();
      } else if (!_isRefreshing && _dragOffset > 0) {
        _animateToZero();
      }
    } else if (notification is OverscrollNotification) {
      final double newOffset = (_dragOffset - notification.overscroll * 0.6)
          .clamp(0.0, _maxPullDistance);
      setState(() {
        _dragOffset = newOffset;
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        (_dragOffset / _refreshTriggerThreshold).clamp(0.0, 1.0);
    final isDark = widget.isDark;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Nuqtali To'lqin (3-Dot Bouncing Wave) Header
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: Center(
                child: Opacity(
                  opacity: progress.clamp(0.2, 1.0),
                  child: _buildDotWaveAnimation(progress, isDark),
                ),
              ),
            ),

          // 2. Main Content
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildDotWaveAnimation(double progress, bool isDark) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final animValue = _waveController.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Offset phase for each of the 3 dots
            final double offsetPhase = index * 0.33;
            final double wave = math
                .sin((animValue * 2 * math.pi) - (offsetPhase * 2 * math.pi));

            // Dynamic energetic vertical bounce (tepaga-pastga to'lqinli tebranish)
            final double translateY = wave * 7.0;
            final double scale = 0.8 + ((wave + 1.0) * 0.22);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 9.5,
                    height: 9.5,
                    decoration: BoxDecoration(
                      color: _getDotColor(index, isDark),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getDotColor(index, isDark)
                              .withValues(alpha: 0.7),
                          blurRadius: 8,
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getDotColor(int index, bool isDark) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD54F); // Taxi Yellow Soft
      case 1:
        return const Color(0xFFFFC107); // Primary Taxi Yellow
      case 2:
        return const Color(0xFFFFA000); // Taxi Yellow Deep
      default:
        return const Color(0xFFFFC107);
    }
  }
}
