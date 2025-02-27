import 'dart:io';

import 'base/app_exception.dart';

typedef ServerKnownExceptionParser = AppException? Function(
  int? statusCode,
  ServerError serverError,
);

class ServerError {
  const ServerError({
    this.errorCode,
    this.message,
    this.fieldErrors = const [],
    this.code,
  });

  final String? errorCode;
  final String? message;
  final List<ServerFieldError> fieldErrors;
  final String? code;

  @override
  String toString() {
    return 'ServerError{errorCode: $errorCode, message: $message, fieldErrors: $fieldErrors, code: $code}';
  }
}

class ServerFieldError {
  const ServerFieldError({
    this.field,
    this.messages = const [],
  });

  final String? field;
  final List<String> messages;

  @override
  String toString() {
    return 'ServerFieldError{field: $field, message: $messages}';
  }
}

class ApiException extends AppException {
  const ApiException({
    required this.kind,
    this.statusCode,
    this.rootException,
    this.serverError,
  }) : super(AppExceptionType.api);

  final ApiExceptionKind kind;
  final int? statusCode;
  final Object? rootException;
  final ServerError? serverError;

  String? get generalServerMessage => serverError?.message;

  @override
  String toString() {
    return 'ApiException{kind: $kind, statusCode: $statusCode, $serverError} ${rootException != null ? 'rootException: $rootException' : ''}';
  }
}

enum ApiExceptionKind {
  noInternet,
  network,
  timeout,
  badRequest,
  cancellation,

  /// server has defined response
  serverDefined,

  /// server has not defined response
  serverUndefined,

  /// error occurs when passing JSON
  decodeError,

  /// error occurs when using incorrect SuccessResponseMapperType
  invalidSuccessResponseMapperType,

  /// error occurs when using incorrect ErrorResponseMapperType
  invalidErrorResponseMapperType,

  /// error occurs when all JSON keys of error response are incorrect
  invalidErrorResponse,

  refreshTokenFailed,
  uploadFileFailed,
  unknown,
}

extension ApiExceptionExtensions on ApiException {
  bool get isBadRequest => statusCode == HttpStatus.badRequest;
  bool get isUnauthorized => statusCode == HttpStatus.unauthorized;
  bool get isForbidden => statusCode == HttpStatus.forbidden;
  bool get isNotFound => statusCode == HttpStatus.notFound;
  bool get isServerError =>
      statusCode != null && statusCode! >= HttpStatus.internalServerError;
}
