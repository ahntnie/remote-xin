import 'dart:ui';

class LocaleConfig {
  LocaleConfig._();

  static final supportedLocales =
      _supportedLocalesCode.map((e) => Locale(e)).toList();
  static const _supportedLocalesCode = ['en', 'vi', 'ja', 'ko', 'ar', 'zh'];

  static const Locale defaultLocale = Locale('en');
}
