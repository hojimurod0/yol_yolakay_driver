import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../utils/currency_formatter.dart';
import '../app_button.dart';
import 'vehicle_2d_seat_fallback.dart';
import 'vehicle_3d_viewer.dart';
import 'vehicle_seat_models.dart';

enum SeatViewMode { threeD, twoD }

/// Premium, responsive seat selection bottom sheet.
/// Offers seamless toggling between an interactive 3D cabin inspector and a 2D top-down seat plan.
class SeatSelectionBottomSheet extends StatefulWidget {
  const SeatSelectionBottomSheet({
    super.key,
    required this.vehicleModel,
    this.vehicleColor = "Oq",
    required this.pricePerSeat,
    this.initialSelectedSeatNumbers = const {1},
    this.occupiedSeatNumbers = const {3},
    required this.onSeatsConfirmed,
    this.isRu = false,
  });

  final String vehicleModel;
  final String vehicleColor;
  final int pricePerSeat;
  final Set<int> initialSelectedSeatNumbers;
  final Set<int> occupiedSeatNumbers;
  final ValueChanged<Set<int>> onSeatsConfirmed;
  final bool isRu;

  static Future<Set<int>?> show(
    BuildContext context, {
    required String vehicleModel,
    String vehicleColor = "Oq",
    required int pricePerSeat,
    Set<int> initialSelectedSeatNumbers = const {1},
    Set<int> occupiedSeatNumbers = const {3},
    bool isRu = false,
  }) {
    return showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SeatSelectionBottomSheet(
          vehicleModel: vehicleModel,
          vehicleColor: vehicleColor,
          pricePerSeat: pricePerSeat,
          initialSelectedSeatNumbers: initialSelectedSeatNumbers,
          occupiedSeatNumbers: occupiedSeatNumbers,
          onSeatsConfirmed: (selected) {
            Navigator.pop(context, selected);
          },
          isRu: isRu,
        );
      },
    );
  }

  @override
  State<SeatSelectionBottomSheet> createState() =>
      _SeatSelectionBottomSheetState();
}

class _SeatSelectionBottomSheetState extends State<SeatSelectionBottomSheet> {
  SeatViewMode _viewMode = SeatViewMode.threeD;
  late Set<int> _selectedSeatNumbers;
  String? _statusFeedbackMessage;

  @override
  void initState() {
    super.initState();
    _selectedSeatNumbers = Set.from(widget.initialSelectedSeatNumbers);
  }

  void _handleSeatTapped(VehicleSeatItem seat) {
    if (!seat.isSelectable) {
      setState(() {
        _statusFeedbackMessage = widget.isRu
            ? "№ ${seat.seatNumber} — ${seat.status.russianDescription}"
            : "№ ${seat.seatNumber} — ${seat.status.uzbekDescription}";
      });
      return;
    }

    setState(() {
      if (_selectedSeatNumbers.contains(seat.seatNumber)) {
        // Only allow unselecting if more than 1 seat is selected
        if (_selectedSeatNumbers.length > 1) {
          _selectedSeatNumbers.remove(seat.seatNumber);
          _statusFeedbackMessage = widget.isRu
              ? "№ ${seat.seatNumber} отменено"
              : "№ ${seat.seatNumber} bekor qilindi";
        } else {
          _statusFeedbackMessage = widget.isRu
              ? "Выберите хотя бы 1 место"
              : "Kamida 1 ta joy tanlanishi kerak";
        }
      } else {
        _selectedSeatNumbers.add(seat.seatNumber);
        _statusFeedbackMessage = widget.isRu
            ? "№ ${seat.seatNumber} (${seat.label}) — ${VehicleSeatStatus.selected.russianDescription}"
            : "№ ${seat.seatNumber} (${seat.label}) — ${VehicleSeatStatus.selected.uzbekDescription}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCost = _selectedSeatNumbers.length * widget.pricePerSeat;

    final currentSeats = VehicleSeatItem.defaultSedanSeats(
      occupiedNumbers: widget.occupiedSeatNumbers,
      selectedNumbers: _selectedSeatNumbers,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: isDark ? AppShadows.darkLg : AppShadows.lg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle Bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF383844)
                      : const Color(0xFFD0D0D8),
                  borderRadius: AppRadius.borderPill,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Header Row: Title & View Mode Switcher (3D vs 2D)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isRu
                          ? "Выбор места в салоне"
                          : "Salonda joy tanlash",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isRu
                          ? "Нажмите на сиденье для выбора"
                          : "Tanlash uchun o'rindiqni bosing",
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),

                // 3D / 2D View Switcher Capsule
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22222A)
                        : const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF30303A)
                          : const Color(0xFFE0E3EA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeSegment(
                        mode: SeatViewMode.threeD,
                        label: "3D",
                        icon: Icons.view_in_ar_rounded,
                        isDark: isDark,
                      ),
                      _buildModeSegment(
                        mode: SeatViewMode.twoD,
                        label: "2D",
                        icon: Icons.map_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Dynamic Viewer: 3D or 2D
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              crossFadeState: _viewMode == SeatViewMode.threeD
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Vehicle3DViewer(
                seats: currentSeats,
                onSeatTapped: _handleSeatTapped,
                vehicleModel: widget.vehicleModel,
                vehicleColorName: widget.vehicleColor,
                isRu: widget.isRu,
              ),
              secondChild: Vehicle2DSeatFallback(
                seats: currentSeats,
                onSeatTapped: _handleSeatTapped,
                vehicleModel: widget.vehicleModel,
                isRu: widget.isRu,
              ),
            ),

            const SizedBox(height: 12),

            // Status Legend Row (Bo'sh, Tanlangan, Band)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: isDark ? const Color(0xFF282830) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF444450)
                      : const Color(0xFFD1D5DB),
                  label: widget.isRu ? "Свободно" : "Bo'sh joy",
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                _buildLegendItem(
                  color: AppColors.taxiYellow,
                  borderColor: AppColors.taxiYellowDark,
                  label: widget.isRu ? "Выбрано" : "Tanlangan",
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                _buildLegendItem(
                  color: isDark
                      ? const Color(0xFF141416)
                      : const Color(0xFF1F1F24),
                  borderColor: isDark
                      ? const Color(0xFF2A2A30)
                      : const Color(0xFF374151),
                  label: widget.isRu ? "Занято" : "Band",
                  isDark: isDark,
                ),
              ],
            ),

            // Contextual Feedback Banner
            if (_statusFeedbackMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow
                      .withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.taxiYellow.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.taxiYellowDark),
                    const SizedBox(width: 6),
                    Text(
                      _statusFeedbackMessage!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.taxiYellow
                            : const Color(0xFF8C6400),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Summary & Dominant CTA Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1F1F26) : const Color(0xFFF6F7FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2B2B34)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isRu
                            ? "Выбрано мест: ${_selectedSeatNumbers.length}"
                            : "Tanlangan: ${_selectedSeatNumbers.length} ta joy (${_selectedSeatNumbers.join(', ')})",
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppCurrencyFormatter.format(totalCost,
                            locale: widget.isRu ? 'ru' : 'uz'),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      text: widget.isRu ? "Выбрать" : "Tasdiqlash",
                      variant: AppButtonVariant.taxi,
                      height: 44,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onSeatsConfirmed(_selectedSeatNumbers);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSegment({
    required SeatViewMode mode,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _viewMode = mode);
      },
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF33333E) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? AppColors.taxiYellow
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.charcoalBlack)
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
