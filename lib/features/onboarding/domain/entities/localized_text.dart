import 'package:equatable/equatable.dart';

/// User-facing text from the config, one entry per language code.
class LocalizedText extends Equatable {
  const LocalizedText(this.values);

  /// Every piece of config text must exist in all of these languages.
  static const Set<String> requiredLanguages = {'en', 'ar'};
  static const String _fallbackLanguage = 'en';

  final Map<String, String> values;

  /// Text for [languageCode], falling back to English.
  String resolve(String languageCode) =>
      values[languageCode] ?? values[_fallbackLanguage] ?? '';

  /// Required languages that are missing or blank.
  Set<String> get missingLanguages => requiredLanguages
      .where((code) => (values[code] ?? '').trim().isEmpty)
      .toSet();

  @override
  List<Object?> get props => [values];
}
