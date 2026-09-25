import 'package:flutter/widgets.dart';

import 'localized_text.dart';

extension LocalizedTextX on LocalizedText {
  /// Resolves the text for the app's current locale.
  String of(BuildContext context) =>
      resolve(Localizations.localeOf(context).languageCode);
}
