import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_notifier.g.dart';

@riverpod
class CounterStateNotifier extends _$CounterStateNotifier {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
