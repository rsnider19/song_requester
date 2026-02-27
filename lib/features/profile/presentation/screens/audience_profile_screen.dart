import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class AudienceProfileScreen extends ConsumerWidget {
  const AudienceProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authStateProvider);
    final isAnonymous = profile?.isAnonymous ?? true;
    final isPerformer = profile?.isPerformer ?? false;
    final mode = ref.watch(appModeProvider);

    return AppScaffold(
      title: const Text('Profile'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isAnonymous ? 'Guest' : (profile?.email ?? ''),
                style: ShadTheme.of(context).textTheme.h4,
              ),
              const Gap(24),
              if (isPerformer) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performer mode',
                      style: ShadTheme.of(context).textTheme.p,
                    ),
                    ShadSwitch(
                      value: mode == AppMode.performer,
                      onChanged: (value) =>
                          ref.read(appModeProvider.notifier).mode = value ? AppMode.performer : AppMode.audience,
                    ),
                  ],
                ),
                const Gap(24),
              ],
              if (!isAnonymous && !isPerformer) ...[
                ShadButton.outline(
                  onPressed: () => context.push('/performer-onboarding'),
                  child: const Text('Become a Performer'),
                ),
                const Gap(12),
              ],
              ShadButton.outline(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
