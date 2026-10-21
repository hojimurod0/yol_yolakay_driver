import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ultra-high performance lazy-loading container for GoRouter [StatefulShellRoute] branches.
/// Lazily instantiates branches only when navigated to for the first time, preventing
/// heavy widgets (like Google Maps or background streams) from overloading system memory and GPU on cold start.
/// Once loaded, branches remain mounted in [IndexedStack] for 0ms tab switching.
class SmoothTabBranchContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const SmoothTabBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<SmoothTabBranchContainer> createState() =>
      _SmoothTabBranchContainerState();
}

class _SmoothTabBranchContainerState extends State<SmoothTabBranchContainer> {
  final Set<int> _activatedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _activatedIndices.add(widget.navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    _activatedIndices.add(currentIndex);

    return IndexedStack(
      index: currentIndex,
      children: List.generate(
        widget.children.length,
        (index) {
          if (_activatedIndices.contains(index)) {
            return widget.children[index];
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
