import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../core/all.dart';
import '../../../core/exceptions/base/exception_mappers.dart';
import '../response_mapper/base/base_error_response_mapper.dart';
import 'dio_api_exception_mapper.dart';

class GraphQLExceptionMapper extends ExceptionMapper {
  GraphQLExceptionMapper(this._errorResponseMapper);

  final BaseErrorResponseMapper<dynamic> _errorResponseMapper;
  // final _serverGraphQLErrorResponseMapper = const ServerGraphQLErrorMapper();

  @override
  AppException map(Object? exception) {
    if (exception is! OperationException) {
      return ApiException(
        kind: ApiExceptionKind.unknown,
        rootException: exception,
      );
    }

    if (exception.linkException?.originalException is DioException) {
      final dioException =
          exception.linkException!.originalException as DioException;
      if (dioException.type == DioExceptionType.badResponse) {
        /// server-defined error
        ServerError? serverError;
        if (dioException.response?.data != null) {
          serverError = dioException.response!.data! is Map
              ? _errorResponseMapper.map(dioException.response!.data!)
              : ServerError(
                  message: dioException.response!.data! is String
                      ? dioException.response!.data! as String
                      : null,
                );
        }

        return ApiException(
          kind: ApiExceptionKind.serverUndefined,
          serverError: serverError,
        );
      } else {
        return DioApiExceptionMapper(
          serverErrorMapper: _errorResponseMapper,
        ).map(exception.linkException?.originalException);
      }
    } else {
      final serverError = ServerError(
        message: exception.graphqlErrors.firstOrNull?.message,
        errorCode:
            exception.graphqlErrors.firstOrNull?.extensions?['code'] as String?,
      );

      return ApiException(
        kind: ApiExceptionKind.serverDefined,
        serverError: serverError,
      );
    }
  }
}
