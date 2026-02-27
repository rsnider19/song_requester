import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;

  Future<void> _signIn(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } on SignInException catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Sign-in unavailable'),
          description: Text(e.message),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(authServiceProvider);

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Song Requester',
                style: ShadTheme.of(context).textTheme.h1,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Sign in to follow performers and save your history.',
                style: ShadTheme.of(context).textTheme.muted,
                textAlign: TextAlign.center,
              ),
              const Gap(48),
              ShadButton(
                onPressed: _loading ? null : () => _signIn(service.signInWithGoogle),
                child: _loading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue with Google'),
              ),
              const Gap(12),
              ShadButton.outline(
                onPressed: _loading ? null : () => _signIn(service.signInWithApple),
                child: _loading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue with Apple'),
              ),
              const Gap(24),
              ShadButton.ghost(
                onPressed: _loading ? null : () => _signIn(service.signInAnonymously),
                child: const Text('Continue as guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
