import 'package:flutter/material.dart';
import 'app_button.dart';

export 'app_button.dart';

/// Legacy AppPrimaryButton wrapper conforming to unified AppButton.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      usePulsingDots: false,
      leadingIcon: icon != null ? Icon(icon, size: 20) : null,
      height: height,
      variant: AppButtonVariant.primary,
    );
  }
}

/// Legacy AppSecondaryButton wrapper conforming to unified AppButton.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      leadingIcon: icon != null ? Icon(icon, size: 20) : null,
      height: height,
      variant: AppButtonVariant.secondary,
    );
  }
}

/// Legacy AppDestructiveButton wrapper conforming to unified AppButton.
class AppDestructiveButton extends StatelessWidget {
  const AppDestructiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      leadingIcon: icon != null ? Icon(icon, size: 20) : null,
      height: height,
      variant: AppButtonVariant.danger,
    );
  }
}

/// Legacy AppOutlinedButton wrapper conforming to unified AppButton.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      leadingIcon: icon != null ? Icon(icon, size: 20) : null,
      height: height,
      variant: AppButtonVariant.outline,
    );
  }
}
