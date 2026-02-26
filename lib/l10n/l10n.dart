import 'package:flutter/widgets.dart';
import 'package:song_requester/l10n/gen/app_localizations.dart';

export 'package:song_requester/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
