import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads the flavor-specific env file and exposes typed accessors.
/// Used only in bootstrap before runApp — not a Riverpod provider.
final class DotEnvService {
  DotEnvService._();

  /// Loads [envPath] (e.g. `'env/.env.development'`) and returns an instance.
  /// Throws if the file is missing or required keys are absent.
  static Future<DotEnvService> load(String envPath) async {
    await dotenv.load(fileName: envPath);
    return DotEnvService._();
  }

  String get supabaseUrl => _require('SUPABASE_URL');
  String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required env var: $key');
    }
    return value;
  }
}
