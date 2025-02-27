// ignore_for_file: depend_on_referenced_packages

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:gql/ast.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../mappers/exception_mappers/graphql_exception_mapper.dart';
import '../../../mappers/response_mapper/base/base_error_response_mapper.dart';
import '../../../mappers/response_mapper/base/base_success_response_mapper.dart';
import '../../interceptors/base_interceptor.dart';
import 'api_client_default_settings.dart';

enum GraphQLMethod { query, mutate }

class GraphQLApiClient {
  GraphQLApiClient({
    this.baseUrl = '',
    this.interceptors = const [],
    this.errorResponseMapperType =
        ApiClientDefaultSettings.defaultErrorResponseMapperType,
    this.connectTimeout = ApiClientDefaultSettings.connectTimeout,
    this.sendTimeout = ApiClientDefaultSettings.sendTimeout,
    this.receiveTimeout = ApiClientDefaultSettings.receiveTimeout,
  }) : _graphQLClient = ValueNotifier<GraphQLClient>(
          GraphQLClient(
            cache: GraphQLCache(),
            link: DioLink(
              baseUrl,
              client: Dio(
                BaseOptions(
                  baseUrl: baseUrl,
                  connectTimeout: connectTimeout,
                  receiveTimeout: receiveTimeout,
                  sendTimeout: sendTimeout,
                ),
              ),
            ),
          ),
        ) {
    final List<Interceptor> interceptors = [
      ...ApiClientDefaultSettings.requiredInterceptors(
        _dio,
        isLogEnabled: false,
      ),
      ...this.interceptors,
    ];

    interceptors.sort(
      (a, b) => (b is BaseInterceptor ? b.priority : -1)
          .compareTo(a is BaseInterceptor ? a.priority : -1),
    );
    _dio.interceptors.addAll(interceptors);
  }

  final ErrorResponseMapperType errorResponseMapperType;
  final String baseUrl;
  final Duration? connectTimeout;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
  final List<Interceptor> interceptors;
  final ValueNotifier<GraphQLClient> _graphQLClient;

  Dio get _dio => (_graphQLClient.value.link as DioLink).client;

  Future<T> query<T>({
    required String document,
    Map<String, dynamic> variables = const {},
    FetchPolicy? fetchPolicy = FetchPolicy.noCache,
    ErrorResponseMapperType? errorResponseMapperType,
    Decoder<T>? decoder,
  }) async {
    return request(
      method: GraphQLMethod.query,
      documentNode: gql(document),
      variables: variables,
      fetchPolicy: fetchPolicy,
      errorResponseMapperType: errorResponseMapperType,
      decoder: decoder,
    );
  }

  Future<T> mutate<T>({
    required String document,
    Map<String, dynamic> variables = const {},
    FetchPolicy? fetchPolicy = FetchPolicy.noCache,
    ErrorResponseMapperType? errorResponseMapperType,
    Decoder<T>? decoder,
  }) async {
    return request(
      method: GraphQLMethod.mutate,
      documentNode: gql(document),
      variables: variables,
      fetchPolicy: fetchPolicy,
      errorResponseMapperType: errorResponseMapperType,
      decoder: decoder,
    );
  }

  Future<T> request<T>({
    required GraphQLMethod method,
    required DocumentNode documentNode,
    Map<String, dynamic> variables = const {},
    FetchPolicy? fetchPolicy = FetchPolicy.noCache,
    ErrorResponseMapperType? errorResponseMapperType,
    Decoder<T>? decoder,
  }) async {
    final response = await _requestByMethod(
      method: method,
      documentNode: documentNode,
      fetchPolicy: fetchPolicy,
      variables: variables,
    );

    if (response.exception != null) {
      throw GraphQLExceptionMapper(
        BaseErrorResponseMapper.fromType(
          errorResponseMapperType ?? this.errorResponseMapperType,
        ),
      ).map(response.exception);
    }

    return BaseSuccessResponseMapper<T, T>.fromType(
      SuccessResponseMapperType.jsonObject,
    ).mapToDataModel(response.data, decoder);
  }

  Future<QueryResult> _requestByMethod({
    required GraphQLMethod method,
    required DocumentNode documentNode,
    required FetchPolicy? fetchPolicy,
    required Map<String, dynamic> variables,
  }) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _dio.interceptors.add(
      CookieManager(
        PersistCookieJar(
          storage: FileStorage('${appDocDir.path}/.cookies/'),
        ),
      ),
    );

    switch (method) {
      case GraphQLMethod.query:
        return _graphQLClient.value.query(
          QueryOptions(
            document: documentNode,
            variables: variables,
            fetchPolicy: fetchPolicy,
          ),
        );
      case GraphQLMethod.mutate:
        return _graphQLClient.value.mutate(
          MutationOptions(
            document: documentNode,
            variables: variables,
            fetchPolicy: fetchPolicy,
          ),
        );
    }
  }
}
