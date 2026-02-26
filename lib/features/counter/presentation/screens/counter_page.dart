import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/counter/presentation/providers/counter_notifier.dart';
import 'package:song_requester/l10n/l10n.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CounterView();
  }
}

class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppScaffold(
      title: Text(l10n.counterAppBarTitle),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CounterText(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShadIconButton(
                  onPressed: () => ref.read(counterStateProvider.notifier).decrement(),
                  icon: const Icon(LucideIcons.minus),
                ),
                const SizedBox(width: 16),
                ShadIconButton(
                  onPressed: () => ref.read(counterStateProvider.notifier).increment(),
                  icon: const Icon(LucideIcons.plus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CounterText extends ConsumerWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterStateProvider);
    return Text(
      '$count',
      style: ShadTheme.of(context).textTheme.h1,
    );
  }
}
