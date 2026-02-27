import 'package:flutter/widgets.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class AudienceHomeScreen extends StatelessWidget {
  const AudienceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    title: Text('Home'),
    body: Center(child: Text('Audience Home — coming soon')),
  );
}
