import 'package:song_requester/app/app.dart';
import 'package:song_requester/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App(), envPath: 'env/.env.staging');
}
