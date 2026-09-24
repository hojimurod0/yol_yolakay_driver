import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';

class LanguageSelectPage extends ConsumerStatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  ConsumerState<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends ConsumerState<LanguageSelectPage> {
  String _selectedLang = 'uz';

  @override
  void initState() {
    super.initState();
    final currentLocale = ref.read(localeNotifierProvider);
    _selectedLang = currentLocale.languageCode;
  }

  void _onLanguageChosen(String code) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLang = code;
    });
  }

  Future<void> _handleContinue() async {
    HapticFeedback.mediumImpact();
    ref.read(localeNotifierProvider.notifier).setLocale(_selectedLang);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_selected_language', true);

    if (mounted) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      final redirectTo = extra?['redirectTo'] as String?;
      context.go(redirectTo ?? '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final languages = [
      {
        'code': 'uz',
        'flag': '🇺🇿',
        'title': 'O\'zbekcha',
        'subtitle': 'Lotin yozuvida',
      },
      {
        'code': 'ru',
        'flag': '🇷🇺',
        'title': 'Русский',
        'subtitle': 'Русский язык',
      },
      {
        'code': 'en',
        'flag': '🇬🇧',
        'title': 'English',
        'subtitle': 'English language',
      },
    ];

    final continueBtnText = _selectedLang == 'ru'
        ? 'Продолжить'
        : (_selectedLang == 'en' ? 'Continue' : 'Davom etish');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Taxi Logo
              const AppLogo(size: 80, showGlow: true, isCircle: true),

              const SizedBox(height: 20),

              // Title and Subtitle (Minimal, Clear)
              Text(
                _selectedLang == 'ru'
                    ? 'Выберите язык'
                    : (_selectedLang == 'en'
                        ? 'Select Language'
                        : 'Tilni tanlang'),
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                _selectedLang == 'ru'
                    ? 'Язык интерфейса приложения'
                    : (_selectedLang == 'en'
                        ? 'App interface language'
                        : 'Ilova interfeysi tili'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Language Cards List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = languages[index];
                    final code = item['code'] as String;
                    final isSelected = _selectedLang == code;

                    return InkWell(
                      onTap: () => _onLanguageChosen(code),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.taxiYellow
                                      .withValues(alpha: 0.12))
                              : (isDark ? AppColors.surfaceDark : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.taxiYellowDark
                                : (isDark
                                    ? AppColors.cardBorderDark
                                    : AppColors.cardBorder),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.25 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Flag Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.gray800
                                    : AppColors.gray100,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item['flag'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Language Names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.charcoalBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    item['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white60
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selected Radio (Taxi Yellow)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.taxiYellow
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.taxiYellowDark
                                      : (isDark
                                          ? Colors.white30
                                          : AppColors.gray300),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: AppColors.charcoalBlack,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Action Button (Taxi Yellow CTA)
              AppButton(
                text: continueBtnText,
                trailingIcon: const Icon(Icons.arrow_forward_rounded, size: 20),
                onPressed: _handleContinue,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
