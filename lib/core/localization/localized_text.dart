import 'package:equatable/equatable.dart';

/// Text that the catalog provides in one or more languages.
///
/// In JSON it is either a plain string (the same text for every language)
/// or an object keyed by language code: `{"ar": "العظام", "en": "Bones"}`.
class LocalizedText extends Equatable {
  const LocalizedText(this.values);

  LocalizedText.single(String text) : values = {fallbackLanguage: text};

  factory LocalizedText.fromJson(Object? json) {
    if (json is String && json.trim().isNotEmpty) {
      return LocalizedText.single(json);
    }
    if (json is Map &&
        json.isNotEmpty &&
        json.values.every((v) => v is String && v.trim().isNotEmpty)) {
      return LocalizedText(Map<String, String>.from(json));
    }
    throw const FormatException(
      'expected a non-empty string or a {"ar": ..., "en": ...} object of non-empty strings',
    );
  }

  static const fallbackLanguage = 'ar';

  /// Language code -> text. Never empty.
  final Map<String, String> values;

  /// Returns the text for [languageCode], falling back to Arabic, then to
  /// whichever language is available.
  String resolve(String languageCode) =>
      values[languageCode] ?? values[fallbackLanguage] ?? values.values.first;

  @override
  List<Object?> get props => [values];
}
