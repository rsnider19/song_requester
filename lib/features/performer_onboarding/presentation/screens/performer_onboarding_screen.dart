import 'dart:async';

import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/router/app_router.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/presentation/providers/performer_onboarding_state_notifier.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class PerformerOnboardingScreen extends ConsumerWidget {
  const PerformerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(performerOnboardingStateProvider);
    final profile = ref.watch(authStateProvider);
    final theme = ShadTheme.of(context);

    ref.listen(performerOnboardingStateProvider, (_, next) {
      if (next is PerformerOnboardingError) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Something went wrong'),
            description: Text(next.message),
          ),
        );
        ref.read(performerOnboardingStateProvider.notifier).resetError();
      } else if (next is PerformerOnboardingSuccess) {
        unawaited(const PerformerStripePromptRoute().push(context));
      }
    });

    final isLoading = onboardingState is PerformerOnboardingLoading;

    return AppScaffold(
      title: const Text('Become a Performer'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Icon(
                        LucideIcons.mic,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'Become a Performer',
                      style: theme.textTheme.h2,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      'Unlock everything you need to run your gigs.',
                      style: theme.textTheme.muted,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),
                    const _BulletPoint(
                      icon: LucideIcons.calendarPlus,
                      title: 'Create and manage gigs',
                      description: 'Schedule events and share your setlist with the audience.',
                    ),
                    const Gap(16),
                    const _BulletPoint(
                      icon: LucideIcons.music,
                      title: 'Build your song library',
                      description: 'Add songs you can play so audiences can request them.',
                    ),
                    const Gap(16),
                    const _BulletPoint(
                      icon: LucideIcons.dollarSign,
                      title: 'Accept tips',
                      description: 'Let fans tip for their favourite songs during your gig.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadButton(
                    onPressed: isLoading || profile == null
                        ? null
                        : () => ref.read(performerOnboardingStateProvider.notifier).confirmOptIn(profile.id),
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm'),
                  ),
                  const Gap(12),
                  ShadButton.ghost(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.p),
              const Gap(2),
              Text(description, style: theme.textTheme.muted),
            ],
          ),
        ),
      ],
    );
  }
}
