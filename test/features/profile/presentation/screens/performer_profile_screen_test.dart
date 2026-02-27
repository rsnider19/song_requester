import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/profile/presentation/screens/performer_profile_screen.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAuthService extends Mock implements AuthService {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockAuthService authService;

  setUp(() {
    authService = _MockAuthService();
  });

  group('PerformerProfileScreen', () {
    testWidgets('renders placeholder content', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.text('Performer Profile'), findsOneWidget);
      expect(find.textContaining('coming soon'), findsOneWidget);
    });

    testWidgets('shows mode toggle set to on', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.text('Performer mode'), findsOneWidget);

      final toggle = tester.widget<ShadSwitch>(find.byType(ShadSwitch));
      expect(toggle.value, isTrue);
    });

    testWidgets('shows sign-out button', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}
