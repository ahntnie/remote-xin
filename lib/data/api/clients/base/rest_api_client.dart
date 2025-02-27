import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/all.dart';
import '../../../mappers/exception_mappers/dio_api_exception_mapper.dart';
import '../../../mappers/response_mapper/base/all.dart';
import '../../interceptors/base_interceptor.dart';
import 'api_client_default_settings.dart';

enum RestMethod { get, post, put, patch, delete }

class RestApiClient {
  RestApiClient({
    required this.baseUrl,
    this.interceptors = const [],
    this.connectTimeout = ApiClientDefaultSettings.connectTimeout,
    this.receiveTimeout = ApiClientDefaultSettings.receiveTimeout,
    this.sendTimeout = ApiClientDefaultSettings.sendTimeout,
    this.defaultSuccessResponseMapperType =
        ApiClientDefaultSettings.defaultSuccessResponseMapperType,
    this.defaultErrorResponseMapperType =
        ApiClientDefaultSettings.defaultErrorResponseMapperType,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            followRedirects: true,
          ),
        )
  // ..httpClientAdapter = IOHttpClientAdapter(
  //     createHttpClient: () {
  //       final client = HttpClient();
  //       client.badCertificateCallback = (cert, host, port) => true;
  //       return client;
  //     },
  //   )
  {
    final List<Interceptor> interceptors = [
      ...ApiClientDefaultSettings.requiredInterceptors(_dio),
      ...this.interceptors,
    ];

    interceptors.sort(
      (a, b) => (b is BaseInterceptor ? b.priority : -1)
          .compareTo(a is BaseInterceptor ? a.priority : -1),
    );

    _dio.interceptors.addAll(interceptors);
  }

  final String baseUrl;
  final Duration? connectTimeout;
  final Duration? receiveTimeout;
  final Duration? sendTimeout;
  final List<Interceptor> interceptors;
  final Dio _dio;
  final SuccessResponseMapperType defaultSuccessResponseMapperType;
  final ErrorResponseMapperType defaultErrorResponseMapperType;

  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    return _dio.fetch(requestOptions);
  }

  Future<T> request<T, D>({
    required RestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Decoder<D>? decoder,
    Map<String, dynamic>? headers,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    try {
      final response = await _requestByMethod<dynamic>(
        method: method,
        path: path.startsWith(baseUrl) ? path.substring(baseUrl.length) : path,
        queryParameters: queryParameters,
        body: body,
        options: Options(headers: headers),
      );

      return BaseSuccessResponseMapper<D, T>.fromType(
        successResponseMapperType ?? defaultSuccessResponseMapperType,
      ).mapToDataModel(response.data, decoder);
    } on DioException catch (error) {
      final serverErrorMapper = BaseErrorResponseMapper.fromType(
        errorResponseMapperType ?? defaultErrorResponseMapperType,
      );

      throw DioApiExceptionMapper(
        serverErrorMapper: serverErrorMapper,
        serverKnownExceptionParser: serverKnownExceptionParser,
      ).map(error);
    } catch (error) {
      rethrow;
    }
  }

  Future<T> get<T, D>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    return request<T, D>(
      method: RestMethod.get,
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<T> post<T, D>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    return request<T, D>(
      method: RestMethod.post,
      path: path,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<T> put<T, D>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    return request<T, D>(
      method: RestMethod.put,
      path: path,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<T> patch<T, D>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    return request<T, D>(
      method: RestMethod.patch,
      path: path,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<T> delete<T, D>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    return request<T, D>(
      method: RestMethod.delete,
      path: path,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<Response<T>> _requestByMethod<T>({
    required RestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    // ignore: avoid-dynamic
    dynamic body,
    Options? options,
  }) {
    switch (method) {
      case RestMethod.get:
        return _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.post:
        return _dio.post(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.patch:
        return _dio.patch(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.put:
        return _dio.put(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.delete:
        return _dio.delete(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
    }
  }

  Future<T> postMultiForm<T, D>(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
    ServerKnownExceptionParser? serverKnownExceptionParser,
  }) async {
    final form = await _parseMultiPartForm(body);

    return request<T, D>(
      method: RestMethod.post,
      path: path,
      queryParameters: queryParameters,
      body: FormData.fromMap(form),
      headers: headers,
      decoder: decoder,
      successResponseMapperType: successResponseMapperType,
      errorResponseMapperType: errorResponseMapperType,
      serverKnownExceptionParser: serverKnownExceptionParser,
    );
  }

  Future<Map<String, dynamic>> _parseMultiPartForm(
    Map<String, dynamic> body,
  ) async {
    final form = <String, dynamic>{};

    final bodyKeys = body.keys.toList();

    for (final String key in bodyKeys) {
      final dynamic value = body[key];

      if (value is String || value is bool) {
        form[key] = value.toString();
      } else if (value is List) {
        form[key] =
            value.map((dynamic item) => item.toString()).toList().join(',');
      } else if (value is File) {
        final fileName = value.path.split('/').last;
        form[key] =
            await MultipartFile.fromFile(value.path, filename: fileName);
      } else {
        throw Exception('Unsupported multiform value type');
      }
    }

    return form;
  }
}
