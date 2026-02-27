import 'package:flutter/widgets.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class GigsScreen extends StatelessWidget {
  const GigsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    title: Text('Gigs'),
    body: Center(child: Text('Gigs — coming soon')),
  );
}
