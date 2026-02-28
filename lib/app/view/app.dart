import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/router/app_router.dart';
import 'package:song_requester/l10n/l10n.dart';

const _colorScheme = ShadColorScheme(
  background: Color(0xFF0D0D12),
  foreground: Color(0xFFF0EDFF),
  card: Color(0xFF1A1A24),
  cardForeground: Color(0xFFF0EDFF),
  popover: Color(0xFF1A1A24),
  popoverForeground: Color(0xFFF0EDFF),
  primary: Color(0xFF7C3AED),
  primaryForeground: Color(0xFFF0EDFF),
  secondary: Color(0xFF22D3EE),
  secondaryForeground: Color(0xFF0D0D12),
  muted: Color(0xFF16161F),
  mutedForeground: Color(0xFF9090A8),
  accent: Color(0xFFA78BFA),
  accentForeground: Color(0xFF0D0D12),
  destructive: Color(0xFFEF4444),
  destructiveForeground: Color(0xFFF0EDFF),
  border: Color(0xFF2A2A3A),
  input: Color(0xFF1A1A24),
  ring: Color(0xFF7C3AED),
  selection: Color(0x557C3AED),
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadApp.router(
      routerConfig: ref.watch(goRouterProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: .dark,
      darkTheme: ShadThemeData(colorScheme: _colorScheme),
    );
  }
}
