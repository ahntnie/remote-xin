import 'package:get/get.dart';

import '../../core/all.dart';
import '../../core/exceptions/custom/all.dart';

class AppExceptionMessageMapper {
  factory AppExceptionMessageMapper() => _instance;
  AppExceptionMessageMapper._();
  static final AppExceptionMessageMapper _instance =
      AppExceptionMessageMapper._();

  String map(AppException exception) {
    switch (exception.type) {
      case AppExceptionType.api:
        return _mapApiException(exception);
      case AppExceptionType.parse:
        return _mapParseException(exception);
      case AppExceptionType.validation:
        return _mapValidationException(exception);
      case AppExceptionType.custom:
        return _mapCustomException(exception) ?? '';
      case AppExceptionType.uncaught:
        return 'Unexpected error';
      default:
        return '';
    }
  }

  String _mapApiException(AppException exception) {
    if (exception is! ApiException) {
      return '';
    }

    switch (exception.kind) {
      case ApiExceptionKind.refreshTokenFailed:
        return Get.context!.l10n.error__token_expired;
      case ApiExceptionKind.noInternet:
        return Get.context!.l10n.error__no_internet;

      case ApiExceptionKind.badRequest:
        return exception.generalServerMessage ?? 'Bad request';
      case ApiExceptionKind.network:
        return 'Network error';
      case ApiExceptionKind.timeout:
        return 'Timeout';
      case ApiExceptionKind.cancellation:
        return 'Request cancelled';
      case ApiExceptionKind.unknown:
        return 'Unknown error';
      case ApiExceptionKind.serverDefined:
        // TODO: Handle this case.
        return '';
      default:
        return '';
    }
  }

  String _mapParseException(AppException exception) {
    if (exception is! ParseException) {
      return '';
    }

    switch (exception.kind) {
      case ParseExceptionKind.invalidSourceFormat:
        return 'Invalid format';
    }
  }

  String _mapValidationException(AppException exception) {
    if (exception is! ValidationException) {
      return '';
    }

    switch (exception.kind) {
      case ValidationExceptionKind.invalidEmail:
      case ValidationExceptionKind.emptyEmail:
      case ValidationExceptionKind.invalidPassword:
      case ValidationExceptionKind.invalidUserName:
      case ValidationExceptionKind.invalidPhoneNumber:
      case ValidationExceptionKind.invalidDateTime:
      case ValidationExceptionKind.passwordsAreNotMatch:
      default:
        return '';
    }
  }

  String? _mapCustomException(AppException exception) {
    if (exception is AuthException) {}

    if (exception is ConversationException) {
      return switch (exception.kind) {
        ConversationExceptionKind.onlyCreatorCanDelete =>
          Get.context!.l10n.chat_delete__error_only_creator
      };
    }

    return null;
  }
}
