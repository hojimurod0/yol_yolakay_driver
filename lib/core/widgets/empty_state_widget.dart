import 'package:flutter/material.dart';
import 'app_empty_state.dart';

export 'app_empty_state.dart';

/// Legacy EmptyStateWidget forwarding to unified AppEmptyState.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.actionIcon,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? actionIcon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      description: description ?? '',
      icon: icon,
      actionText: actionText,
      onAction: onAction,
    );
  }
}
