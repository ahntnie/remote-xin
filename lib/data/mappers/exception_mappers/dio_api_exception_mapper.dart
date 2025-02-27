import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/all.dart';
import '../../../core/exceptions/base/exception_mappers.dart';
import '../response_mapper/base/all.dart';

class DioApiExceptionMapper implements ExceptionMapper {
  const DioApiExceptionMapper({
    required this.serverErrorMapper,
    this.serverKnownExceptionParser,
  });

  final BaseErrorResponseMapper serverErrorMapper;
  final ServerKnownExceptionParser? serverKnownExceptionParser;

  @override
  AppException map(Object? exception) {
    if (exception is ApiException) {
      return exception;
    }

    if (exception is! DioException) {
      return ApiException(
        kind: ApiExceptionKind.unknown,
        rootException: exception,
      );
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          kind: ApiExceptionKind.timeout,
          rootException: exception,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          kind: ApiExceptionKind.network,
          rootException: exception,
        );
      case DioExceptionType.cancel:
        return ApiException(
          kind: ApiExceptionKind.cancellation,
          rootException: exception,
        );
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;

        if (exception.response?.data != null) {
          final serverError = exception.response!.data! is Map
              ? serverErrorMapper.mapToServerError(exception.response!.data!)
              : ServerError(message: exception.response!.data!);

          final knownException = serverKnownExceptionParser?.call(
            statusCode,
            serverError,
          );

          return knownException ??
              ApiException(
                kind: ApiExceptionKind.serverDefined,
                statusCode: statusCode,
                serverError: serverError,
                rootException: exception,
              );
        }

        return ApiException(
          kind: ApiExceptionKind.serverUndefined,
          statusCode: statusCode,
          rootException: exception,
        );
      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return ApiException(
            kind: ApiExceptionKind.network,
            rootException: exception,
          );
        }

        if (exception.error is ApiException) {
          return exception.error as ApiException;
        }
      default:
        return ApiException(
          kind: ApiExceptionKind.unknown,
          rootException: exception,
        );
    }

    return ApiException(
      kind: ApiExceptionKind.unknown,
      rootException: exception,
    );
  }
}
