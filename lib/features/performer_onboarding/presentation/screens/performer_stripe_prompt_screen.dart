import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class PerformerStripePromptScreen extends ConsumerWidget {
  const PerformerStripePromptScreen({super.key});

  void _enterPerformerMode(BuildContext context, WidgetRef ref) {
    ref.read(appModeProvider.notifier).mode = AppMode.performer;
    // Router refresh will redirect to /performer/gigs via the mode-sync guard.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    return AppScaffold(
      title: const Text('Set Up Payments'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Icon(
                  LucideIcons.creditCard,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(24),
              Text(
                "You're a performer!",
                style: theme.textTheme.h2,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Connect Stripe to accept tips from your audience.',
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              ShadCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.zap, size: 16),
                        const Gap(8),
                        Text('Why connect Stripe?', style: theme.textTheme.p),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      'Stripe lets you receive tips securely. '
                      'You must complete Stripe KYC before starting a gig with tips enabled.',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ShadButton(
                onPressed: () {
                  ShadToaster.of(context).show(
                    const ShadToast(
                      title: Text('Coming soon'),
                      description: Text('Stripe setup will be available in a future update.'),
                    ),
                  );
                  _enterPerformerMode(context, ref);
                },
                child: const Text('Set up Stripe'),
              ),
              const Gap(12),
              ShadButton.ghost(
                onPressed: () => _enterPerformerMode(context, ref),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
