import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A tab descriptor for [AppShellScreen].
class AppShellTab {
  const AppShellTab({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// App-level shell that renders a [StatefulNavigationShell] with a
/// shadcn-themed bottom navigation bar.
///
/// Used by both the Audience and Performer shells in the app router.
class AppShellScreen extends StatelessWidget {
  const AppShellScreen({
    required this.navigationShell,
    required this.tabs,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppShellTab> tabs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNavBar(
        tabs: tabs,
        selectedIndex: navigationShell.currentIndex,
        onTabSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<AppShellTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: shadTheme.colorScheme.card,
        border: Border(
          top: BorderSide(color: shadTheme.colorScheme.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavBarItem(
                    tab: tabs[i],
                    selected: i == selectedIndex,
                    onTap: () => onTabSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final color = selected ? shadTheme.colorScheme.foreground : shadTheme.colorScheme.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: 22, color: color),
          const Gap(4),
          Text(
            tab.label,
            style: shadTheme.textTheme.small.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
