import 'package:flutter/widgets.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

// TODO(team): add widget test when content is implemented
class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    title: Text('Songs'),
    body: Center(child: Text('Songs — coming soon')),
  );
}
