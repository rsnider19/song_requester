import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/presentation/screens/sign_in_screen.dart';

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

  group('SignInScreen', () {
    testWidgets('renders Google and Apple sign-in buttons', (tester) async {
      await tester.pumpApp(
        const SignInScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('shows destructive toast when Google sign-in fails', (tester) async {
      when(
        () => authService.signInWithGoogle(),
      ).thenThrow(const SignInException('Google Sign-In is not yet implemented'));

      await tester.pumpApp(
        const ShadToaster(child: SignInScreen()),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Sign-in unavailable'), findsOneWidget);
    });

    testWidgets('shows destructive toast when Apple sign-in fails', (tester) async {
      when(
        () => authService.signInWithApple(),
      ).thenThrow(const SignInException('Apple Sign-In is not yet implemented'));

      await tester.pumpApp(
        const ShadToaster(child: SignInScreen()),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(find.text('Sign-in unavailable'), findsOneWidget);
    });

    testWidgets('both buttons are disabled and show spinners while loading', (tester) async {
      final completer = Completer<void>();
      when(() => authService.signInWithGoogle()).thenAnswer((_) => completer.future);

      await tester.pumpApp(
        const SignInScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pump(); // One frame — still loading

      // Both buttons should have null onPressed (disabled) while loading.
      final buttons = tester.widgetList<ShadButton>(find.byType(ShadButton));
      for (final button in buttons) {
        expect(button.onPressed, isNull, reason: 'All buttons must be disabled during loading');
      }

      // Both buttons should show a spinner while loading.
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

      completer.complete();
    });
  });
}
