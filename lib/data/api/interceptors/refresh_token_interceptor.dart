import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/all.dart';
import 'base_interceptor.dart';

class RefreshTokenInterceptor extends BaseInterceptor {
  RefreshTokenInterceptor();

  @override
  int get priority => BaseInterceptor.refreshTokenPriority;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      final options = err.response!.requestOptions;
      const error = ApiException(kind: ApiExceptionKind.refreshTokenFailed);

      handler.reject(
        DioException(requestOptions: options, error: error),
      );
    } else {
      handler.next(err);
    }
  }
}
