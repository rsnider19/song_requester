import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_requester/features/counter/counter.dart';

void main() {
  group('CounterStateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is 0', () {
      expect(container.read(counterStateProvider), equals(0));
    });

    test('state is 1 after increment', () {
      container.read(counterStateProvider.notifier).increment();
      expect(container.read(counterStateProvider), equals(1));
    });

    test('state is -1 after decrement', () {
      container.read(counterStateProvider.notifier).decrement();
      expect(container.read(counterStateProvider), equals(-1));
    });
  });
}
