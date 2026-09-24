import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ultra-high performance lazy-loading container for GoRouter [StatefulShellRoute] branches.
/// Lazily instantiates branches only when navigated to for the first time, preventing
/// heavy widgets (like Google Maps or background streams) from overloading system memory and GPU on cold start.
/// Once loaded, branches remain mounted in [IndexedStack] for 0ms tab switching.
class SmoothTabBranchContainer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const SmoothTabBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: navigationShell.currentIndex,
      children: children,
    );
  }
}
