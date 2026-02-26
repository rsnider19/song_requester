import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that notifies GoRouter when the auth state changes.
/// Wrap a stream so router layer does not depend on auth presentation layer.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
