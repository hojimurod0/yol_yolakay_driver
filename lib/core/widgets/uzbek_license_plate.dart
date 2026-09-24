import 'package:flutter/material.dart';

/// Authentic Uzbekistan Vehicle License Plate Widget (O'zbekiston Davlat Raqam Belgisi).
/// Accurately renders real-world Uzbekistan license plates:
/// [ Region Code (e.g. 10 / 01 / 60) | Main Number (e.g. A 111 AA) | 🇺🇿 UZ ]
class UzbekLicensePlate extends StatelessWidget {
  const UzbekLicensePlate({
    super.key,
    required this.plateNumber,
    this.height = 24.0,
    this.fontSize,
    this.showFlag = true,
  });

  final String plateNumber;
  final double height;
  final double? fontSize;
  final bool showFlag;

  /// Parses plate strings like "10 A 111 AA", "01 777 BAA", "60 A 777 BA", "10A111AA"
  static ({String region, String number}) parsePlate(String raw) {
    final cleaned = raw.trim().toUpperCase();
    if (cleaned.isEmpty) return (region: '01', number: 'A 001 AA');

    // Check if starts with 2 digits (e.g. 01, 10, 60, 40)
    final match = RegExp(r'^(\d{2})\s*(.*)$').firstMatch(cleaned);
    if (match != null) {
      final region = match.group(1) ?? '01';
      final rest = match.group(2) ?? '';
      return (region: region, number: rest.isNotEmpty ? rest : '001 AAA');
    }

    return (region: '01', number: cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parsePlate(plateNumber);
    final calculatedFontSize = fontSize ?? (height * 0.52);

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height * 0.16),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Region Code (e.g. "10", "01", "60", "40")
          Text(
            parsed.region,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: calculatedFontSize,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
            ),
          ),

          // 2. Vertical Divider Line
          Container(
            margin: EdgeInsets.symmetric(horizontal: height * 0.16),
            width: 1.2,
            height: height * 0.72,
            color: const Color(0xFF1E293B),
          ),

          // 3. Main Registration Number (e.g. "A 111 AA", "001 VIP")
          Text(
            parsed.number,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: calculatedFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),

          // 4. Uzbekistan Flag & "UZ" Country Identifier
          if (showFlag) ...[
            SizedBox(width: height * 0.16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Realistic UZ Flag
                Container(
                  width: height * 0.44,
                  height: height * 0.28,
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
                      Expanded(child: Container(color: Colors.white)), // White
                      Container(
                          height: 0.6,
                          color: const Color(0xFFCE1126)), // Red stripe
                      Expanded(
                          child: Container(
                              color: const Color(0xFF1EB53A))), // Green
                    ],
                  ),
                ),
                Text(
                  'UZ',
                  style: TextStyle(
                    color: const Color(0xFF003399),
                    fontSize: calculatedFontSize * 0.45,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
