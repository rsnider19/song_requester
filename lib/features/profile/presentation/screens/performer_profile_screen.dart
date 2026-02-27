import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class PerformerProfileScreen extends ConsumerWidget {
  const PerformerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    title: const Text('Profile'),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Performer Profile', style: ShadTheme.of(context).textTheme.h4),
            const Gap(8),
            Text('Gigs, songs, tips and QR code — coming soon.', style: ShadTheme.of(context).textTheme.muted),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Performer mode', style: ShadTheme.of(context).textTheme.p),
                ShadSwitch(
                  value: true,
                  onChanged: (_) => ref.read(appModeProvider.notifier).mode = AppMode.audience,
                ),
              ],
            ),
            const Gap(24),
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
