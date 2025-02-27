import 'package:dio/dio.dart';

import 'base_interceptor.dart';

class TrimInterceptor extends BaseInterceptor {
  @override
  int get priority => BaseInterceptor.trimPriority;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is Map) {
      final data = options.data as Map;
      data.forEach((dynamic key, dynamic value) {
        if (value is String) {
          final finalValue = value.trim().isEmpty ? null : value.trim();
          data[key] = finalValue;
        }
      });
    }
    handler.next(options);
  }
}
