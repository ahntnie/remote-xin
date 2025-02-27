import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../mappers/response_mapper/base/all.dart';
import '../../interceptors/all.dart';

class ApiClientDefaultSettings {
  const ApiClientDefaultSettings._();

  static const connectTimeout = Duration(seconds: 60);
  static const receiveTimeout = Duration(seconds: 60);
  static const sendTimeout = Duration(seconds: 60);

  static const defaultErrorResponseMapperType =
      ErrorResponseMapperType.jsonObject;
  static const defaultSuccessResponseMapperType =
      SuccessResponseMapperType.jsonObject;

  static List<Interceptor> requiredInterceptors(
    Dio dio, {
    bool isLogEnabled = true,
  }) =>
      [
        if (kDebugMode && isLogEnabled) CustomLogInterceptor(),
        ConnectivityInterceptor(),
        RefreshTokenInterceptor(),
        TrimInterceptor(),
        RetryInterceptor(dio),
      ];
}
