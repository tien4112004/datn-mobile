import 'package:AIPrimary/i18n/strings.g.dart';

enum Language {
  english,
  vietnamese;

  String get code {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.vietnamese:
        return 'vi';
    }
  }

  String get apiValue {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.vietnamese:
        return 'vi';
    }
  }

  factory Language.fromApiValue(String apiValue) {
    switch (apiValue) {
      case 'en':
        return Language.english;
      case 'vi':
        return Language.vietnamese;
      default:
        return Language.english;
    }
  }

  String getDisplayName(Translations t) {
    switch (this) {
      case Language.english:
        return t.locale_en;
      case Language.vietnamese:
        return t.locale_vi;
    }
  }

  static List<String> getSupportedLanguages(Translations t) {
    return Language.values
        .map((language) => language.getDisplayName(t))
        .toList();
  }
}
