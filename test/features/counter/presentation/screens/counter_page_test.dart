// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/counter/counter.dart';
import 'package:song_requester/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _FixedCounterNotifier extends CounterStateNotifier {
  _FixedCounterNotifier(this._value);

  final int _value;

  @override
  int build() => _value;
}

void main() {
  group('CounterPage', () {
    testWidgets('renders CounterView', (tester) async {
      await tester.pumpApp(CounterPage());
      expect(find.byType(CounterView), findsOneWidget);
    });
  });

  group('CounterView', () {
    testWidgets('renders current count', (tester) async {
      const state = 42;
      await tester.pumpApp(
        CounterView(),
        overrides: [
          counterStateProvider.overrideWith(() => _FixedCounterNotifier(state)),
        ],
      );
      expect(find.text('$state'), findsOneWidget);
    });

    testWidgets('increments count when increment button is tapped', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ShadApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CounterView(),
          ),
        ),
      );
      expect(container.read(counterStateProvider), 0);
      await tester.tap(find.byIcon(LucideIcons.plus));
      expect(container.read(counterStateProvider), 1);
    });

    testWidgets('decrements count when decrement button is tapped', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ShadApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CounterView(),
          ),
        ),
      );
      expect(container.read(counterStateProvider), 0);
      await tester.tap(find.byIcon(LucideIcons.minus));
      expect(container.read(counterStateProvider), -1);
    });
  });
}
