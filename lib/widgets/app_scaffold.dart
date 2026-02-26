import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A custom scaffold that wraps [Scaffold] and [AppBar] with app-level styling.
///
/// Use this instead of [Scaffold] directly in all feature screens.
/// If a screen needs a top navigation bar, pass a [title] widget.
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
    final shadTheme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: shadTheme.colorScheme.background,
      appBar: title != null
          ? AppBar(
              title: DefaultTextStyle(
                style: TextStyle(color: shadTheme.colorScheme.foreground),
                child: title!,
              ),
              backgroundColor: shadTheme.colorScheme.card,
              iconTheme: IconThemeData(color: shadTheme.colorScheme.foreground),
              elevation: 0,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
