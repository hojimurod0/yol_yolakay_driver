import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Uzbekistan Regions Data Model
class UzRegion {
  final String code;
  final String nameUz;
  final String nameRu;

  const UzRegion({
    required this.code,
    required this.nameUz,
    required this.nameRu,
  });
}

/// Official List of all 14 Uzbekistan Region Plate Codes
const List<UzRegion> kUzbekistanRegions = [
  UzRegion(code: '01', nameUz: 'Toshkent shahri', nameRu: 'г. Ташкент'),
  UzRegion(
      code: '10', nameUz: 'Toshkent viloyati', nameRu: 'Ташкентская область'),
  UzRegion(
      code: '20', nameUz: 'Sirdaryo viloyati', nameRu: 'Сырдарьинская область'),
  UzRegion(code: '25', nameUz: 'Jizzax viloyati', nameRu: 'Джизакская область'),
  UzRegion(
      code: '30',
      nameUz: 'Samarqand viloyati',
      nameRu: 'Самаркандская область'),
  UzRegion(
      code: '40', nameUz: 'Farg\'ona viloyati', nameRu: 'Ферганская область'),
  UzRegion(
      code: '50', nameUz: 'Namangan viloyati', nameRu: 'Наманганская область'),
  UzRegion(
      code: '60', nameUz: 'Andijon viloyati', nameRu: 'Андижанская область'),
  UzRegion(
      code: '70',
      nameUz: 'Qashqadaryo viloyati',
      nameRu: 'Кашкадарьинская область'),
  UzRegion(
      code: '75',
      nameUz: 'Surxondaryo viloyati',
      nameRu: 'Сурхандарьинская область'),
  UzRegion(code: '80', nameUz: 'Buxoro viloyati', nameRu: 'Бухарская область'),
  UzRegion(code: '85', nameUz: 'Navoiy viloyati', nameRu: 'Навоийская область'),
  UzRegion(code: '90', nameUz: 'Xorazm viloyati', nameRu: 'Хорезмская область'),
  UzRegion(
      code: '95',
      nameUz: 'Qoraqalpog\'iston Resp.',
      nameRu: 'Респ. Каракалпакстан'),
];

/// Authentic interactive Uzbekistan Vehicle License Plate Input Widget.
/// Renders an authentic license plate input:
/// [ Region Code (01/40/60) ▾ | Main Number (e.g. D 555 AA / 777 AAA) | 🇺🇿 UZ ]
class UzbekLicensePlateInput extends StatefulWidget {
  const UzbekLicensePlateInput({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.isDark = false,
    this.isRu = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final bool isRu;

  @override
  State<UzbekLicensePlateInput> createState() => _UzbekLicensePlateInputState();
}

class _UzbekLicensePlateInputState extends State<UzbekLicensePlateInput> {
  late String _selectedRegion;
  late TextEditingController _numberController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _parseInitialValue(widget.initialValue);
    _numberController.addListener(_handleNumberChange);
  }

  void _parseInitialValue(String raw) {
    final clean = raw.trim().toUpperCase();
    final match = RegExp(r'^(\d{2})\s*(.*)$').firstMatch(clean);
    if (match != null) {
      _selectedRegion = match.group(1) ?? '01';
      final rest = match.group(2) ?? '';
      _numberController = TextEditingController(text: rest);
    } else if (clean.length >= 2 &&
        int.tryParse(clean.substring(0, 2)) != null) {
      _selectedRegion = clean.substring(0, 2);
      _numberController =
          TextEditingController(text: clean.substring(2).trim());
    } else {
      _selectedRegion = '01';
      _numberController =
          TextEditingController(text: clean.isNotEmpty ? clean : 'A 777 AA');
    }
  }

  void _handleNumberChange() {
    final numText = _numberController.text.trim().toUpperCase();
    final fullPlate = '$_selectedRegion $numText'.trim();
    widget.onChanged(fullPlate);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant UzbekLicensePlateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final clean = widget.initialValue.trim().toUpperCase();
      final match = RegExp(r'^(\d{2})\s*(.*)$').firstMatch(clean);
      if (match != null) {
        final newReg = match.group(1) ?? '01';
        final newNum = match.group(2) ?? '';
        if (newReg != _selectedRegion || newNum != _numberController.text) {
          _selectedRegion = newReg;
          _numberController.text = newNum;
        }
      }
    }
  }

  @override
  void dispose() {
    _numberController.removeListener(_handleNumberChange);
    _numberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openRegionPicker() {
    HapticFeedback.selectionClick();
    _focusNode.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.white24 : AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isRu
                            ? 'Выберите регион (код)'
                            : 'Hudud kodi (Viloyat)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? Colors.white
                              : AppColors.charcoalBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    color: widget.isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorder),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    itemCount: kUzbekistanRegions.length,
                    itemBuilder: (ctx, index) {
                      final reg = kUzbekistanRegions[index];
                      final isSelected = reg.code == _selectedRegion;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedRegion = reg.code;
                            });
                            _handleNumberChange();
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.taxiYellow.withValues(alpha: 0.15)
                                  : (widget.isDark
                                      ? AppColors.gray900
                                      : AppColors.gray50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.taxiYellowDark
                                    : (widget.isDark
                                        ? AppColors.cardBorderDark
                                        : AppColors.cardBorder),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Region Code Badge
                                Container(
                                  width: 42,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFF1E293B),
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    reg.code,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    widget.isRu ? reg.nameRu : reg.nameUz,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: widget.isDark
                                          ? Colors.white
                                          : AppColors.charcoalBlack,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.taxiYellowDark,
                                      size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Realistic Uzbekistan License Plate Box
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B), width: 2.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Interactive Region Code Box (e.g. 01 / 40 / 60)
              InkWell(
                onTap: _openRegionPicker,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedRegion,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical Plate Divider
              Container(
                width: 2.0,
                height: 44,
                color: const Color(0xFF1E293B),
              ),

              // 2. Main Number Text Input (e.g. "D 555 AA" or "777 AAA")
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _numberController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 21,
                      letterSpacing: 2.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'D 555 AA',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: 2.0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-zA-Z\s]')),
                      LengthLimitingTextInputFormatter(10),
                      _UzPlateTextFormatter(),
                    ],
                  ),
                ),
              ),

              // Vertical Plate Divider
              Container(
                width: 2.0,
                height: 44,
                color: const Color(0xFF1E293B),
              ),

              // 3. Official Uzbekistan Flag & "UZ" Identifier
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Realistic Uzbekistan Flag
                    Container(
                      width: 20,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        border: Border.all(color: Colors.black26, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                              child: Container(
                                  color: const Color(0xFF0099B5))), // Cyan Blue
                          Container(
                              height: 0.6,
                              color: const Color(0xFFCE1126)), // Red stripe
                          Expanded(
                              child: Container(color: Colors.white)), // White
                          Container(
                              height: 0.6,
                              color: const Color(0xFFCE1126)), // Red stripe
                          Expanded(
                              child: Container(
                                  color: const Color(0xFF1EB53A))), // Green
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'UZ',
                      style: TextStyle(
                        color: Color(0xFF003399),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Quick Region Selector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickRegionChip('01', 'Toshkent sh.'),
              _buildQuickRegionChip('40', 'Farg\'ona'),
              _buildQuickRegionChip('60', 'Andijon'),
              _buildQuickRegionChip('50', 'Namangan'),
              _buildQuickRegionChip('30', 'Samarqand'),
              _buildQuickRegionChip('80', 'Buxoro'),
              _buildQuickRegionChip('70', 'Qashqadaryo'),
              _buildQuickRegionChip('90', 'Xorazm'),
              _buildQuickRegionChip('10', 'Toshkent v.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRegionChip(String code, String label) {
    final isSelected = _selectedRegion == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedRegion = code;
          });
          _handleNumberChange();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.taxiYellow.withValues(alpha: 0.25)
                : (widget.isDark ? AppColors.gray800 : AppColors.gray100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.taxiYellowDark
                  : (widget.isDark
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorder),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            '$code $label',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (widget.isDark
                      ? AppColors.taxiYellow
                      : AppColors.charcoalBlack)
                  : (widget.isDark ? Colors.white70 : AppColors.charcoalBlack),
            ),
          ),
        ),
      ),
    );
  }
}

/// Auto-formats Uzbek car plate numbers (e.g. "D 555 AA", "A 777 AA", "777 AAA")
class _UzPlateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final uppercase = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: uppercase,
      selection: TextSelection.collapsed(offset: uppercase.length),
    );
  }
}
