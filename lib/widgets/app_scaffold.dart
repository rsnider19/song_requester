import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// App-level scaffold — a pure shadcn alternative to Material's Scaffold.
///
/// Provides an optional top app bar and an optional floating action button
/// overlay. Screens are responsible for their own [SafeArea] in [body].
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? title;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) _AppBar(title: title!, theme: theme),
          Expanded(
            child: _maybeRemoveTopPadding(
              context: context,
              removeTop: title != null,
              child: floatingActionButton != null
                  ? Stack(
                      children: [
                        body,
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: floatingActionButton!,
                        ),
                      ],
                    )
                  : body,
            ),
          ),
        ],
      ),
    );
  }
}

/// When the app bar is present it already consumes the top safe-area inset.
/// Strip that inset from [MediaQuery] so descendant [SafeArea] widgets in the
/// body don't double-apply it.
Widget _maybeRemoveTopPadding({
  required BuildContext context,
  required bool removeTop,
  required Widget child,
}) {
  if (!removeTop) return child;
  return MediaQuery.removePadding(
    context: context,
    removeTop: true,
    child: child,
  );
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title, required this.theme});

  final Widget title;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DefaultTextStyle(
            style: theme.textTheme.h4.copyWith(color: theme.colorScheme.foreground),
            child: title,
          ),
        ),
      ),
    );
  }
}
