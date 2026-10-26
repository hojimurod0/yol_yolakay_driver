import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Drag the yellow knob to the end to confirm. Used for actions a driver
/// must not trigger by an accidental tap while driving.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
  });

  final String label;
  final Future<void> Function() onConfirmed;
  final bool enabled;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  static const _height = 62.0;
  static const _knob = 52.0;
  double _dx = 0;
  bool _busy = false;

  Future<void> _finish(double max) async {
    if (_dx < max * 0.85) {
      setState(() => _dx = 0);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _dx = max;
      _busy = true;
    });
    try {
      await widget.onConfirmed();
    } finally {
      if (mounted) {
        setState(() {
          _dx = 0;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.enabled && !_busy ? () => widget.onConfirmed() : null,
      child: LayoutBuilder(builder: (context, c) {
        final max = c.maxWidth - _knob - 10;
        return Container(
          height: _height,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3C4),
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: _knob + 10),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 5 + _dx,
                child: GestureDetector(
                  onHorizontalDragUpdate: widget.enabled && !_busy
                      ? (d) => setState(
                          () => _dx = (_dx + d.delta.dx).clamp(0.0, max))
                      : null,
                  onHorizontalDragEnd:
                      widget.enabled && !_busy ? (_) => _finish(max) : null,
                  child: Container(
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryHover.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _busy
                        ? const Padding(
                            padding: EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.textPrimaryLight),
                          )
                        : const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.textPrimaryLight),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
