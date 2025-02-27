import '../../../../core/all.dart';
import '../error_response/all.dart';

enum ErrorResponseMapperType {
  jsonObject,
}

abstract class BaseErrorResponseMapper<T> {
  const BaseErrorResponseMapper();

  factory BaseErrorResponseMapper.fromType(ErrorResponseMapperType type) {
    switch (type) {
      case ErrorResponseMapperType.jsonObject:
        return JsonObjectErrorResponseMapper() as BaseErrorResponseMapper<T>;
    }
  }

  ServerError map(dynamic errorResponse) {
    try {
      if (errorResponse is! T) {
        throw ApiException(
          kind: ApiExceptionKind.invalidErrorResponseMapperType,
          rootException: 'Response is not $T',
        );
      }

      final serverError = mapToServerError(errorResponse);

      if (serverError.errorCode == null && serverError.message == null) {
        throw ApiException(
          kind: ApiExceptionKind.invalidErrorResponse,
          rootException: '$errorResponse is invalid, $serverError is empty',
        );
      }

      return serverError;
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(kind: ApiExceptionKind.decodeError, rootException: e);
    }
  }

  ServerError mapToServerError(T? errorResponse);

  AppException? mapToKnownException(
    ServerError serverError, {
    int? statusCode,
  }) {
    return null;
  }
}
