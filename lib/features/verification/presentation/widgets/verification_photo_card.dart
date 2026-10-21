import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive Document / Vehicle Photo Upload Card with preview and actions.
class VerificationPhotoCard extends StatelessWidget {
  const VerificationPhotoCard({
    super.key,
    required this.title,
    required this.fieldKey,
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
    this.subtitle,
    this.icon = Icons.camera_alt_outlined,
    this.isDark = false,
  });

  final String title;
  final String fieldKey;
  final String imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final String? subtitle;
  final IconData icon;
  final bool isDark;

  bool get hasPhoto => imagePath.isNotEmpty;

  void _showFullScreenPreview(BuildContext context) {
    if (!hasPhoto) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = hasPhoto
        ? AppColors.success
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      height: 135,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: hasPhoto ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Uploaded Image Preview (tap to view full screen)
                  GestureDetector(
                    onTap: () => _showFullScreenPreview(context),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.grey, size: 36),
                      ),
                    ),
                  ),

                  // 2. Verified Badge Top Right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Yuklandi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Gradient Action Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Title caption
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // View Fullscreen Action
                          InkWell(
                            onTap: () => _showFullScreenPreview(context),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          // Change photo Action
                          InkWell(
                            onTap: onPick,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_rounded,
                                color: AppColors.taxiYellow,
                                size: 18,
                              ),
                            ),
                          ),
                          // Delete photo Action
                          InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPick,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow
                                .withValues(alpha: isDark ? 0.18 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 24,
                            color: AppColors.taxiYellowDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.charcoalBlack,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C38)
                                : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 12,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.charcoalBlack,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  'Rasm yuklash',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.charcoalBlack,
                                  ),
                                ),
                              ),
                            ],
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
}
