import '../../all.dart';

abstract class AppException implements Exception {
  const AppException(this.type);

  final AppExceptionType type;

  static AppException unexpectedError({Object? rootError}) {
    return AppUncaughtException(rootError);
  }
}

enum AppExceptionType {
  api,
  parse,
  validation,
  custom,
  uncaught,
}
