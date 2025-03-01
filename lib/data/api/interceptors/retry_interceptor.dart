import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/server/retry_on_error_constants.dart';
import 'base_interceptor.dart';

class RetryInterceptor extends BaseInterceptor {
  RetryInterceptor(
    this._dio, {
    int maxRetries = RetryOnErrorConstants.maxRetries,
    Duration retryInterval = RetryOnErrorConstants.retryInterval,
  })  : _retryInterval = retryInterval,
        _maxRetries = maxRetries;

  final Dio _dio;
  final Duration _retryInterval;
  int _maxRetries;

  static const _retryHeaderKey = 'x-retry';

  @override
  int get priority => BaseInterceptor.retryPriority;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey(_retryHeaderKey)) {
      _maxRetries = RetryOnErrorConstants.maxRetries;
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_maxRetries > 0 && shouldRetry(err)) {
      await Future<void>.delayed(_retryInterval);
      _maxRetries--;
      try {
        return await _dio
            .fetch<dynamic>(err.requestOptions..headers[_retryHeaderKey] = true)
            .then((value) => handler.resolve(value));
      } catch (e) {
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }

  bool shouldRetry(DioException error) {
    return error.type != DioExceptionType.cancel &&
        error.error != null &&
        error.error is SocketException;
  }
}
