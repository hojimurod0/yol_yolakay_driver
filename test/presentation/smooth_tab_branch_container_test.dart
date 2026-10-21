import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yol_yolakay_driver/core/widgets/smooth_tab_branch_container.dart';

void main() {
  testWidgets(
      'SmoothTabBranchContainer lazily mounts branches only upon navigation',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/tab-0',
      routes: [
        StatefulShellRoute(
          builder: (context, state, navigationShell) => Scaffold(
            body: navigationShell,
            bottomNavigationBar: Row(
              children: [
                TextButton(
                  onPressed: () => navigationShell.goBranch(0),
                  child: const Text('Nav 0'),
                ),
                TextButton(
                  onPressed: () => navigationShell.goBranch(1),
                  child: const Text('Nav 1'),
                ),
              ],
            ),
          ),
          navigatorContainerBuilder: (context, navigationShell, children) {
            return SmoothTabBranchContainer(
              navigationShell: navigationShell,
              children: children,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab-0',
                  builder: (_, __) => const Text('Tab 0 Content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab-1',
                  builder: (_, __) => const Text('Tab 1 Content'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Tab 0 is mounted on cold start, Tab 1 is not mounted anywhere in widget tree
    expect(find.text('Tab 0 Content'), findsOneWidget);
    expect(find.text('Tab 1 Content', skipOffstage: false), findsNothing);

    // Switch to Tab 1
    await tester.tap(find.text('Nav 1'));
    await tester.pumpAndSettle();

    // Tab 1 is now visible on-stage, and Tab 0 remains mounted offstage in IndexedStack
    expect(find.text('Tab 1 Content'), findsOneWidget);
    expect(find.text('Tab 0 Content', skipOffstage: false), findsOneWidget);
  });
}
