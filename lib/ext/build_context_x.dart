import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  Locale get currentAppLocale => Localizations.localeOf(this);
}
